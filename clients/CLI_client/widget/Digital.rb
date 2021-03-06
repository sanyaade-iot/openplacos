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

module Openplacos
  module Digital
    module Order
      include Digital

      module Switch
        include Order
        
        def render
          ret = super
          if ret
            "\033[42m #{ret} \033[0m"
          else
            "\033[41m #{ret} \033[0m"
          end
        end
      end
      
    end
  end

end
