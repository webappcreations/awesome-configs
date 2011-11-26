local setmetatable = setmetatable
local ipairs       = ipairs
local table        = table
local print        = print
local button       = require( "awful.button"      )
local beautiful    = require( "beautiful"         )
local naughty      = require( "naughty"           )
local tag          = require( "awful.tag"         )
local util         = require( "awful.util"        )
local common       = require( "ultiLayout.common" )

local capi = { image  = image  ,
               widget = widget }

module("ultiLayout.vertical")

function new(cg) 
   local data = {}
   data.ratio = {}
   local nb =0
   
   local function make_room(percentage) --Between 0 and 1
       local nb = #cg:childs()
       local shrinking_factor = 1 - percentage
       for k,v in ipairs(cg:childs()) do
           data.ratio[v] = (data.ratio[v] or 1)*shrinking_factor
       end
   end
   
    function data:gen_vertex(vertex_list)
        local prev = nil
        local nb2   = 0
        for k,v in ipairs(cg:childs()) do
            if prev and nb2 ~= nb then
                local aVertex = common.create_vertex({x=v.x,y=cg.y,orientation="vertical",length=cg.height})
                aVertex.cg1 = prev
                aVertex.cg2 = v
                table.insert(vertex_list,aVertex)
            end
            v:get_vertex(vertex_list)
            prev = v
            nb2 = nb2+1
        end
        return vertex_list
    end
   
   function data:update()
       local relX   = cg.x
       local relY   = cg.y
       for k,v in ipairs(cg:childs()) do
           v:geometry({width  = cg.width*data.ratio[v], height = cg.height, x      = relX, y      = relY})
           v:repaint()
           relX     = relX + (cg.width*data.ratio[v])
--            relY     = relY + (height*data.ratio[v])
       end
   end
   
   function data:add_child(child_cg)
       nb = nb + 1
       local percent = 1 / nb
       make_room(percent)
       data.ratio[child_cg] = percent
   end
   return data
end

common.add_new_layout("vertical",new)

setmetatable(_M, { __call = function(_, ...) return new(...) end })