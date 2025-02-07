%define name     zabbix-agent-custom
%define version  4.4.4
%define release  20200424
%define prefix   /srv/%{name}
%define packager MySafeZone <matthieu@mysafezone.fr>
%define source   zabbix-%{version}.tar.gz
%define user     zabbixcustom
%define uid      10001


Name:           %{name}
Version:        %{version}
Release:        6%{?dist}
Summary:        Custom Zabbix Agent
URL:            https://zabbix.mysafezone.fr/
Group:          Networking/Admin
License:        GPLv2+
Source0:        %{source}
Patch0:         zabbix_agentd.patch
Packager:       %{packager}

BuildRequires:  gcc
Requires:       sudo
Requires:       logrotate

%description
Zabbix Agent with customize parameters

%prep
%setup -n zabbix-%{version}
%patch0 -p1
mkdir -p %{prefix}

%build
./configure --prefix=%{prefix} --enable-agent --with-libpcre-lib
make %{?_smp_mflags}


%install
rm -rf %{buildroot}
make install DESTDIR=%{buildroot}
mkdir -p %{buildroot}/usr/lib/systemd/system
install -m 755 $RPM_SOURCE_DIR/zabbix-agent-custom.service %{buildroot}/usr/lib/systemd/system
mkdir -p %{buildroot}/etc/sudoers.d
install -m 440 $RPM_SOURCE_DIR/zabbix-agent-custom.sudo %{buildroot}/etc/sudoers.d/zabbix-agent-custom
mkdir -p %{buildroot}/%{prefix}/run
mkdir -p %{buildroot}/etc/logrotate.d
install -m 440 $RPM_SOURCE_DIR/zabbix-agent-custom.logrotate %{buildroot}/etc/logrotate.d/zabbix-agent-custom
mkdir -p %{buildroot}/var/log/zabbix

%clean
rm -rf %{buildroot}

%files
%defattr(-,zabbixcustom,zabbixcustom,-)
%{prefix}/
%{prefix}/*
/usr/lib/systemd/system/zabbix-agent-custom.service
%attr(440,root,root) /etc/sudoers.d/zabbix-agent-custom
%attr(440,root,root) /etc/logrotate.d/zabbix-agent-custom
%config %{prefix}/etc/zabbix_agentd.conf

%doc

%pre
if [ "$1" = "1" ]; then #first install only - not for an update
	/usr/bin/getent group %{user} || groupadd %{user}
	/usr/bin/getent passwd %{user} || useradd -M -d %{prefix} -s /bin/bash -g %{user} %{user}
fi

%post
mkdir -p /var/run/zabbixcustom
chown %{user}:%{user} /var/run/zabbixcustom
mkdir -p /var/log/zabbix/
chown %{user}:%{user} /var/log/zabbix
mkdir -p %{prefix}/lock
chown %{user}:%{user} %{prefix}/lock
	
HOSTNAME=`hostname -s`
sed -i "s/#HOSTNAME#/$HOSTNAME/" %{prefix}/etc/zabbix_agentd.conf
systemctl daemon-reload
systemctl start %{name}
systemctl enable %{name}

%preun
if [ "$1" = "1" ]; then # executed only during an update
	systemctl stop %{name}
fi
if [ "$1" = "0" ]; then # executed only during an uninstall, not during an update
	pkill -9 -u %{user}
	skill -KILL -u %{user}
	systemctl stop %{name}
	systemctl disable %{name}
	systemctl daemon-reload
	systemctl reset-failed
fi

%postun
if [ "$1" = "0" ]; then # executed only during an uninstall, not during an update
	userdel -r %{user}
fi

%changelog
* Fri Apr 24 2020 Matthieu Ackermann <matthieu@mysafezone.fr> - v4.4.4-6
- Added condition in the %postun/%preun section to support an update of the package (previously the %postun section of the new version of the package was executed after the %post section of the old version of the package and all were lost in %post. The result was that all files were deleted after an update)
- Added rotation to the log file (with logrotate) 
* Wed Apr 22 2020 Matthieu Ackermann <matthieu@mysafezone.fr> - v4.4.4-5
- Activation of service run during system startup
* Tue Feb 18 2020 Matthieu Ackermann <matthieu@mysafezone.fr> - v4.4.4-4
- Move the PID file to /srv/zabbix-agent-custom/run/zabbix-agent-custom.pid
- Modify the default listen port (10060 instead of 10051)
* Fri Feb 14 2020 Matthieu Ackermann <matthieu@mysafezone.fr> - v4.4.4-3
- Move the default installation directory to /srv/zabbix-agent-custom
* Wed Feb 05 2020 Matthieu Ackermann <matthieu@mysafezone.fr> - v4.4.4-2
- Minor modification to patch original configuration file zabix_agentd.conf from the sources (only a diff file is used instead of the complete configuration file)
* Mon Feb 03 2020 Matthieu Ackermann <matthieu@mysafezone.fr>- v4.4.4-1
- Initial version of the package of Zabbix Agent v4.4.4

