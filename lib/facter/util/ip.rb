module Facter::IPAddress
    
    def self.get_interfaces
    
     int = nil
    
     case Facter.value(:kernel)
        when 'Linux', 'OpenBSD', 'NetBSD', 'FreeBSD'
           output = %x{/sbin/ifconfig -a}       
        when 'SunOS'
           output = %x{/usr/sbin/ifconfig -a} 
     end
    
     # We get lots of warnings on platforms that don't get an output
     # made.
     if output
         int = output.scan(/^\w+[.:]?\d+/)
     else
         []
     end
    
    end
    
    def self.get_interface_value_nonbsd(interface, label)
    
    tmp1 = nil

    case Facter.value(:kernel)
      when 'Linux'
       output_int = %x{/sbin/ifconfig #{interface}}
       addr = /inet addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
       mac  = /(?:ether|HWaddr)\s+(\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2}:\w{1,2})/
       mask = /Mask:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
     when 'OpenBSD', 'NetBSD', 'FreeBSD'
       output_int = %x{/sbin/ifconfig #{interface}}
       addr = /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
       mac  = /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
       mask = /netmask\s+(\w{10})/
    when 'SunOS'
       output_int = %x{/usr/sbin/ifconfig #{interface}}
       addr = /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
       mac  = /(?:ether|lladdr)\s+(\w?\w:\w?\w:\w?\w:\w?\w:\w?\w:\w?\w)/
       mask = /netmask\s+(\w{8})/
    end

    case label
      when 'ipaddress'
       regex = addr
      when 'macaddress'
       regex = mac
      when 'netmask'
       regex = mask
    end 
     
      if interface != "lo" && interface != "lo0"
        output_int.each { |s|
           tmp1 = $1 if s =~ regex
       }
      end

      if tmp1 
        value = tmp1
      end

   end

   def self.get_interface_value_bsd(interface, label)

    tmp1 = []

    int_hash = {}
    output_int = %x{/sbin/ifconfig #{interface}}
    addr = /inet\s+([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)/
    mac  = /(?:ether|lladdr)\s+(\w\w:\w\w:\w\w:\w\w:\w\w:\w\w)/
    mask = /netmask\s+(\w{10})/

    case label
      when 'ipaddress'
       regex = addr
      when 'macaddress'
       regex = mac
      when 'netmask'
       regex = mask
    end

    if interface != "lo" && interface != "lo0"
      output_int.each { |s|
        tmp1.push($1) if s =~ regex
      }
    end

    if tmp1
       value = tmp1.shift
    end

   end
end

