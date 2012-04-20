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
#
#
#    LM335 temperature sensor component

require File.dirname(__FILE__) << "/LibComponent.rb"

component = LibComponent::Component.new(ARGV) do |c|
  c.description  "DHT11 temperature and humidity sensor"
  c.version "0.1"
  c.default_name "dht11"
end

component << Raw = LibComponent::Output.new("/raw","dht11","r")
component << C_temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.celcuis")
component << F_temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.farenheit")
component << K_temp = LibComponent::Input.new("/temperature","analog.sensor.temperature.kelvin")

component << Hum = LibComponent::Input.new("/humidity","analog.sensor.humidity.rh")

class DHT11
  attr_reader :H , :T
  def initialize
    @T = nil
    @H = nil
    @last_call = Time.new(0)
  end
  
  def read(*args)
    if Time.now - @last_call > 0.5
      ret = Raw.read(*args)
      @H = ret["humidity"]
      @T = ret["temperature"]
    end
    return 0
  end
end

dht11 = DHT11.new

Hum.on_read do |*args|
  dht11.read(*args)
  return dht11.H
end
  
C_temp.on_read do |*args|
  dht11.read(*args)
  return dht11.T
end

F_temp.on_read do |*args|
  return 9.0/5.0*C_temp.read(*args) + 32 
end

K_temp.on_read do |*args|
  return C_temp.read(*args) + 273
end

component.run
