# Copyright IBM Corp. 2018, 2026
# SPDX-License-Identifier: MPL-2.0

# syntax=docker/dockerfile:1

FROM redhat/ubi9

WORKDIR /

RUN dnf --assumeyes upgrade && dnf --assumeyes install openssh-server sudo

RUN mkdir -p /etc/sudoers.d

# create test users
RUN arr=("danielle" "oliver") && \
for i in "${arr[@]}"; do \
    user="$i"; \
    useradd -m -g users $user; \
    echo "$user:YnkXV/6g1+Bd7fKKjfM07g==" | chpasswd; \
    echo "$user ALL=NOPASSWD:/usr/sbin/chpasswd" > "/etc/sudoers.d/$user"; \
done

# Ensure sshd allows password logins
RUN echo "PasswordAuthentication yes" > /etc/ssh/sshd_config.d/40-local-passwords.conf

# Clear and regenerate host key for sshd
RUN rm -rvf /etc/ssh/ssh_host_*_key* \
    && ssh-keygen -A

EXPOSE 22

# Run
CMD ["/usr/sbin/sshd", "-D"]
