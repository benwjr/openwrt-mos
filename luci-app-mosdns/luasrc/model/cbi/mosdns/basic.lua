m = Map("mosdns")
m.title = translate("MosDNS")
m.description = translate("MosDNS is a 'programmable' DNS forwarder.")

m:section(SimpleSection).template = "mosdns/mosdns_status"

s = m:section(TypedSection, "mosdns")
s.addremove = false
s.anonymous = true

enable = s:option(Flag, "enabled", translate("Enable"))
enable.rmempty = false

configfile = s:option(ListValue, "configfile", translate("MosDNS Config File"))
configfile:value("./def_config.yaml", translate("Def Config"))
configfile:value("./cus_config.yaml", translate("Cus Config"))
configfile.default = "./def_config.yaml"

loglv = s:option(ListValue, "loglv", translate("Log Level"))
loglv:value("debug")
loglv:value("info")
loglv:value("warn")
loglv:value("error")
loglv.default = "error"
loglv:depends( "configfile", "./def_config.yaml")

logfile = s:option(Value, "logfile", translate("MosDNS Log File"))
logfile.placeholder = "/dev/null"
logfile.default = "/dev/null"
logfile:depends( "configfile", "./def_config.yaml")

remote_dns = s:option(Value, "remote_dns1", translate("Remote DNS"))
remote_dns.rmempty = false
remote_dns.default = "tls://8.8.4.4"
remote_dns:value("tls://8.8.8.8", "8.8.8.8 (Google DNS)")
remote_dns:value("tls://8.8.4.4", "8.8.4.4 (Google DNS)")
remote_dns:value("tls://9.9.9.9", "9.9.9.9 (Quad9 DNS)")
remote_dns:value("tls://1.1.1.1", "1.1.1.1 (CloudFlare DNS)")
remote_dns:value("tls://185.222.222.222", "185.222.222.222 (DNS.SB)")
remote_dns:value("tls://45.11.45.11", "45.11.45.11 (DNS.SB)")
remote_dns:value("208.67.222.222", "208.67.222.222 (Open DNS)")
remote_dns:value("208.67.220.220", "208.67.220.220 (Open DNS)")
remote_dns:depends( "configfile", "./def_config.yaml")
remote_dns = s:option(Value, "remote_dns2", " ")
remote_dns.rmempty = false
remote_dns.default = "tls://9.9.9.9"
remote_dns:value("tls://8.8.8.8", "8.8.8.8 (Google DNS)")
remote_dns:value("tls://8.8.4.4", "8.8.4.4 (Google DNS)")
remote_dns:value("tls://9.9.9.9", "9.9.9.9 (Quad9 DNS)")
remote_dns:value("tls://1.1.1.1", "1.1.1.1 (CloudFlare DNS)")
remote_dns:value("tls://185.222.222.222", "185.222.222.222 (DNS.SB)")
remote_dns:value("tls://45.11.45.11", "45.11.45.11 (DNS.SB)")
remote_dns:value("208.67.222.222", "208.67.222.222 (Open DNS)")
remote_dns:value("208.67.220.220", "208.67.220.220 (Open DNS)")
remote_dns:depends( "configfile", "./def_config.yaml")

redirect = s:option(Flag, "redirect", translate("Enable DNS Redirect"))
redirect:depends( "configfile", "./def_config.yaml")
redirect.default = true

adblock = s:option(Flag, "adblock", translate("Enable DNS ADblock"))
adblock:depends( "configfile", "./def_config.yaml")
adblock.default = true

set_config = s:option(Button, "set_config", translate("DNS Helper"))
set_config.inputtitle = translate("Apply")
set_config.inputstyle = "reload"
set_config.description = translate("This will make the necessary adjustments to other plug-in settings.")
set_config.write = function()
  luci.sys.exec("/etc/mosdns/set.sh &> /dev/null &")
end
set_config:depends( "configfile", "./def_config.yaml")

unset_config = s:option(Button, "unset_config", translate("Revert Settings"))
unset_config.inputtitle = translate("Apply")
unset_config.inputstyle = "reload"
unset_config.description = translate("This will revert the adjustments.")
unset_config.write = function()
  luci.sys.exec("/etc/mosdns/set.sh unset &> /dev/null &")
end

config = s:option(TextValue, "manual-config")
config.description = translate("<font color=\"ff0000\"><strong>View the Custom YAML Configuration file used by this MosDNS. You can edit it as you own need.")
config.template = "cbi/tvalue"
config.rows = 25
config:depends( "configfile", "./cus_config.yaml")

function config.cfgvalue(self, section)
  return nixio.fs.readfile("/etc/mosdns/cus_config.yaml")
end

function config.write(self, section, value)
  value = value:gsub("\r\n?", "\n")
  nixio.fs.writefile("/etc/mosdns/cus_config.yaml", value)
end

config = s:option(TextValue, "whitelist")
config.description = translate("<font color=\"ff0000\"><strong>ADblock whitelist.")
config.template = "cbi/tvalue"
config.rows = 25
config:depends( "configfile", "./def_config.yaml")

function config.cfgvalue(self, section)
  return nixio.fs.readfile("/etc/mosdns/whitelist.txt")
end

function config.write(self, section, value)
  value = value:gsub("\r\n?", "\n")
  nixio.fs.writefile("/etc/mosdns/whitelist.txt", value)
end

return m
