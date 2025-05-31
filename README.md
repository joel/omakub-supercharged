# Omakub Supercharged

![Image](https://github.com/user-attachments/assets/796dd22f-37cd-4651-8162-a5ef474258f5)

![Image](https://github.com/user-attachments/assets/61114043-9f00-4045-b0b0-ca84a743a07a)

# Extra Configuration

Finger print

Install the necessary package if you haven't already:

```bash
sudo apt update
sudo apt install libpam-fprintd
```

Edit the PAM configuration file for sudo. Open it with a text editor:
```bash
sudo nvim /etc/pam.d/sudo
```

Add the following line at the beginning of the file:
```bash
auth sufficient pam_fprintd.so
```

# Extra Installations

[Back In Time](https://github.com/bit-team/backintime)

```bash
sudo apt install backintime-qt
```





