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
#

require 'Pin.rb'

class Export
    attr_reader :pin_web, :dbus_name, :ifaces

  def initialize(config_)
    @config     = config_
    @dbus_name  = @config
    @pin_web = Pin_web.new(config_)
  end
  
  def update_ifaces # plugged ifaces will be mine
    @pin_web.update_ifaces
  end

 end
