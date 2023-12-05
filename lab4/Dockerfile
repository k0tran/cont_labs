FROM ubuntu:20.04

LABEL author="Sorochan I.V."
LABEL email="none"
LABEL version="0.1.0"
LABEL description="wgdashboard + wireguard + ubuntu"

RUN adduser user01 --disabled-password && \
    echo "user01 ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# Update
# Sudoers = hotfix
RUN apt-get update -y && \
    rm -rf /etc/sudoers && \
    apt-get install -y wireguard iproute2 net-tools git python3-pip gunicorn && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setup wireguard config
RUN echo -n "[Interface]\nPrivateKey = " > /etc/wireguard/wg0.conf && \
    wg genkey | tee -a /etc/wireguard/wg0.conf | wg pubkey > publickey && \
    echo -n "Address = 10.0.0.1/" >> /etc/wireguard/wg0.conf && \
    ip -of inet addr show eth0 | awk '{split($4, a, "/"); print a[2]}' >> /etc/wireguard/wg0.conf && \
    echo "ListenPort = 51820" >> /etc/wireguard/wg0.conf && \
    echo -n "\n[Peer]]\nPublicKey = " >> /etc/wireguard/wg0.conf && \
    cat publickey >> /etc/wireguard/wg0.conf && rm -f publickey && \
    echo "AllowedIPs = 0.0.0.0/0" >> /etc/wireguard/wg0.conf

# Setup wg-dashboard
RUN cd /usr/local/share && \
    git clone -b v3.0.6 https://github.com/donaldzou/WGDashboard.git wgdashboard && \
    cd wgdashboard/src && \
    chmod u+x wgd.sh && ./wgd.sh install && \
    sudo chmod -R 755 /etc/wireguard

EXPOSE 51820/udp
EXPOSE 10086/tcp

WORKDIR /app

ENTRYPOINT ["/bin/bash", "-c", "wg-quick up wg0 && cd /usr/local/share/wgdashboard/src && ./wgd.sh start && tail -f /dev/null"]
