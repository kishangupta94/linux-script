apt install bind9 dnsutils apache2 openssl
read -p "Domain: " domain
read -p "FQ: " fq
dns1=$(cat /etc/bind/named.conf.local | grep -o "$domain"| sort -u)
if [ ! -z "$dns1" ];then
	printf "Domain [$domain] exists.\n"
	exit 127
fi

printf "zone \"$domain\" {\n\ttype\tmaster;\n\tfile\t\"/etc/bind/db.$domain\";\n};\n" >> /etc/bind/named.conf.local

#To get ip of host machine
ip=$(ip a | grep "inet " | grep -v "inet 127" | awk -F ' ' '{print $2}' | cut -d "/" -f 1)
echo "
; BIND data file for local loopback interface
;
\$TTL    604800
@       IN      SOA     debian.$domain. root.$domain. (
                              2         ; Serial
                         604800         ; Refresh
                          86400         ; Retry
                        2419200         ; Expire
                         604800 )       ; Negative Cache TTL
;
@       IN      NS      $domain.
debian       IN      A       $ip
\$fq       IN      A       $ip
@       IN      A       $ip
@       IN      AAAA    ::1" > /etc/bind/db.$domain


#/etc/resolv.conf
sed -i "1d" /etc/resolv.conf
sed -i "1d" /etc/resolv.conf
sed -i "1idomain \$domain" /etc/resolv.conf
sed -i "2isearch \$domain" /etc/resolv.conf
sed -i "3inameserver \$ip" /etc/resolv.conf

systemctl restart bind9
host $domain