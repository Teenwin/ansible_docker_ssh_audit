FROM alpine:latest

RUN echo "root:root" | chpasswd
RUN apk add --no-cache openssh-server sudo python3 py3-pip
RUN ssh-keygen -A

RUN sed -i 's/#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#*PubkeyAuthentication.*/PubkeyAuthentication no/' /etc/ssh/sshd_config && \
    sed -i 's/#*PermitEmptyPasswords.*/PermitEmptyPasswords no/' /etc/ssh/sshd_config
EXPOSE 22
CMD ["/usr/sbin/sshd","-D"]