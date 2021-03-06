#!/usr/bin/env ruby
#    This file is part of Openplacos.
#
#    Openplacos is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    Openplacos is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with Openplacos.  If not, see <http://www.gnu.org/licenses/>.

THIS_FILE = File.symlink?(__FILE__) ? File.readlink(__FILE__) : __FILE__

require "bundler"
Bundler.setup(:clients, :cliclient)

require "openplacos/libclient"
require 'rink'
require 'micro-optparse'
require File.expand_path(File.dirname(THIS_FILE)) + "/widget/modules.rb"

options = Parser.new do |p|
  p.banner = "OpenplacOS CLI"
  p.option :host, "host server url", :default => "http://localhost:4567"
  p.option :type, "OAuth2 grant type (auth_code, password)", :default => "password", :value_in_set => ["auth_code","password"]
  p.option :username, "If password Oauth2 flow selected, provide username (optional)", :default => ""
  p.option :password, "If password Oauth2 flow selected, provide password (optional)", :default => ""
end.process!

if options[:session]
  ENV['DEBUG_OPOS'] = "1"
end

host=options[:host]

if options[:type]=="password"
  if options[:username]!=""
    username = options[:username]
  else
    require 'highline/import' # interactive
    username =  ask("Enter your username:  ") { |q| q.echo = true }
  end
  if options[:password]!=""
    password = options[:password]
  else
    require 'highline/import' # interactive
    password =  ask("Enter your password:  ") { |q| q.echo = false }
  end
end

begin
  Opos = Openplacos::Client.new(host, "truc", ["read", "user"], options[:type], 0,{:username => username, :password=>password} ) # Beurk -- Constant acting as a global variable
rescue
  puts "Authentification failure"
  Process.exit 255
end

class OpenplacOS_Console < Rink::Console
  command :help do 
    usage
  end

  command :me do
    puts Opos.me
  end
  
  command :usage do 
    usage
  end

  command :list do
    list
  end

  command :status do 
    status
  end

  command :get do |args|
    objects  = Opos.objects

    obj_name = args[0]
    if (!objects.include?(obj_name))
      puts "Object #{obj_name} does not exist"
      next # instead of return
    end
    obj      = objects[obj_name]

    iface    = "#{args[1]}"
    if (!obj.has_iface?(iface))
      puts "Interface #{iface} does not exist"
      next
    end
    puts "- " <<  obj_name
    display(iface, obj[iface].render.to_s)
  end
 
  command :set  do |args|
    objects  = Opos.objects
    
    obj_name = args[0]
    if (!objects.include?(obj_name))
      puts "Object #{obj_name} does not exist"
      next # instead of return
    end
    obj      = objects[obj_name]

    iface    = "#{args[1]}"
    if (!obj.has_iface?(iface))
      puts "Interface #{iface} does not exist"
      next
    end

    command = args
    command.delete_at(0)
    command.delete_at(0)
    obj[iface].set(command.join(" "))
    
  end

  def usage()

    puts "Usage: "
    puts "me                               # Return username"
    puts "list                             # Return sensor and actuator list and corresponding interface "
    puts "status                           # Return a status of your placos"
    puts "get  <object>  <iface>           # Make a read access on this object"
    puts "set  <object>  <iface>  <value>  # Make a write access on this object"
    # puts "regul <sensor>  <threshold>   \n   # Setup up a regul on this sensor with this threeshold"

  end

  def status
    objects = Opos.objects
    objects.each_pair{ |key, obj|
      if (key != "/informations")
        puts "- " << key 
        obj.interfaces.each{ |iface|
          display(iface, obj[iface].render.to_s)
        }
      end
    }
  end
  
  def list
    objects = Opos.objects
    objects.each_pair{ |key, obj|
      if (key != "/informations")
        puts "- " << key 
        obj.interfaces.each{ |iface|
          display(iface, "")
        }
      end
    }
  end

  def display(iface_, value_)
    iface_short = iface_.sub("org.openplacos.", "")
    blank = ""
    printf "\t\t%s %#{50-iface_short.length}s \t%s\n", iface_short, blank, value_
  end

end

OpenplacOS_Console.new
