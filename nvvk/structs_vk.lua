local header = 
[[
/* auto generated by structs_vk.lua */

/* Copyright (c) 2018, NVIDIA CORPORATION. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *  * Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *  * Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 *  * Neither the name of NVIDIA CORPORATION nor the names of its
 *    contributors may be used to endorse or promote products derived
 *    from this software without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
 * EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
 * PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 * OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

//////////////////////////////////////////////////////////////////////////
/**
  # function nvvk::make, nvvk::clear
  Contains templated `nvvk::make<T>` and `nvvk::clear<T>` functions that are 
  auto-generated by `structs.lua`. The functions provide default 
  structs for the Vulkan C api by initializing the `VkStructureType sType`
  field (also for nested structs) and clearing the rest to zero.

  ``` c++
  auto compCreateInfo = nvvk::make<VkComputePipelineCreateInfo>;
  ```
*/
 
#pragma once
]]

-- HOW TO USE
--
-- 1. Setup environment variable NVVK_VULKAN_XML pointing to vk.xml
--    or use VULKAN_SDK >= 1.2.135.0
--
-- 2. Modify the extension whitelist
--
-- 3. Check out this and the other structs_vk files for write access
--
-- 4. Run with a lua5.1 compatible lua runtime and the lua2xml project
--    https://github.com/manoelcampos/xml2lua
--    (shared_internal has all the files).
--
--    lua structs_vk.lua
--
--    within this directory.

local VULKAN_XML = os.getenv("NVVK_VULKAN_XML") or os.getenv("VULKAN_SDK").."/share/vulkan/registry/vk.xml"
local extensionSubset = [[
    VK_KHR_ray_tracing
    VK_KHR_push_descriptor
    VK_KHR_8bit_storage
    VK_KHR_create_renderpass2
    VK_KHR_depth_stencil_resolve
    VK_KHR_draw_indirect_count
    VK_KHR_driver_properties
    VK_KHR_pipeline_executable_properties
    
    VK_NV_compute_shader_derivatives
    VK_NV_cooperative_matrix
    VK_NV_corner_sampled_image
    VK_NV_coverage_reduction_mode
    VK_NV_dedicated_allocation_image_aliasing
    VK_NV_mesh_shader
    VK_NV_ray_tracing
    VK_NV_representative_fragment_test
    VK_NV_shading_rate_image
    VK_NV_viewport_array2
    VK_NV_viewport_swizzle
    VK_NV_scissor_exclusive
    VK_NV_device_generated_commands
    
    VK_EXT_buffer_device_address
    VK_EXT_debug_marker
    VK_EXT_calibrated_timestamps
    VK_EXT_conservative_rasterization
    VK_EXT_descriptor_indexing
    VK_EXT_depth_clip_enable
    VK_EXT_memory_budget
    VK_EXT_memory_priority
    VK_EXT_pci_bus_info
    VK_EXT_sample_locations
    VK_EXT_sampler_filter_minmax
    VK_EXT_texel_buffer_alignment
    VK_EXT_debug_utils
    VK_EXT_host_query_reset
    
    VK_KHR_external_memory_win32
    VK_KHR_external_semaphore_win32
    VK_KHR_external_fence_win32

    VK_KHR_external_memory_fd
    VK_KHR_external_semaphore_fd
    
    VK_EXT_validation_features
    VK_KHR_swapchain
    ]]
    

local function generate(outfilename, header, whitelist)
  
  local override = {
    VkRayTracingShaderGroupCreateInfoNV = 
[[
  template<> inline VkRayTracingShaderGroupCreateInfoNV make<VkRayTracingShaderGroupCreateInfoNV>(){
    VkRayTracingShaderGroupCreateInfoNV ret = {VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_NV};
    ret.generalShader = VK_SHADER_UNUSED_NV;
    ret.closestHitShader = VK_SHADER_UNUSED_NV;
    ret.anyHitShader = VK_SHADER_UNUSED_NV;
    ret.intersectionShader = VK_SHADER_UNUSED_NV;
    return ret;
  }
]],
    VkRayTracingShaderGroupCreateInfoKHR = 
[[
  template<> inline VkRayTracingShaderGroupCreateInfoKHR make<VkRayTracingShaderGroupCreateInfoKHR>(){
    VkRayTracingShaderGroupCreateInfoKHR ret = {VK_STRUCTURE_TYPE_RAY_TRACING_SHADER_GROUP_CREATE_INFO_KHR};
    ret.generalShader = VK_SHADER_UNUSED_KHR;
    ret.closestHitShader = VK_SHADER_UNUSED_KHR;
    ret.anyHitShader = VK_SHADER_UNUSED_KHR;
    ret.intersectionShader = VK_SHADER_UNUSED_KHR;
    return ret;
  }
]],
}

  local function toTab(str)
    local tab = {}
    for name in str:gmatch("[%w_]+") do 
      tab[name] = true
    end
    return tab
  end
  
  local whitelist = whitelist and toTab(whitelist)
  
  local xml2lua = require("xml2lua")
  local handler = require("xmlhandler.tree")
  local filename = VULKAN_XML
  local f = io.open(filename,"rt")
  assert(f, filename.." not found")
  
  local xml = f:read("*a")
  f:close()
  
  -- Bug workaround https://github.com/manoelcampos/xml2lua/issues/35
  xml = xml:gsub("(<member>)(<type>[%w_]+</type>)%* ", function(p,typ)
        -- add _ dummy symbol
        return "<member>_"..typ.."* "
      end)
    
  local parser = xml2lua.parser(handler)
  parser:parse(xml)
  
  local version = xml:match("VK_HEADER_VERSION</name> (%d+)")
  assert(version)
  
  local structenums = {}
  local structextensions = {}
  
  local function enumID(name)
    name = name:lower()
    name = name:gsub("_","")
    return name
  end
  
  for name in xml:gmatch('"VK_STRUCTURE_TYPE_([%w_]-)"') do
    structenums[enumID(name)] = "VK_STRUCTURE_TYPE_"..name
  end
  
  xml = nil 

  local types   = handler.root.registry.types
  local commands   = handler.root.registry.commands
  local extensions = handler.root.registry.extensions.extension
  
  -- debugging
  if (false) then
    local serpent = require "serpent"
    local f = io.open(filename..".types.lua", "wt")
    f:write(serpent.block(types))
    local f = io.open(filename..".exts.lua", "wt")
    f:write(serpent.block(extensions))
  end
  
  -- build list struct types with structure type init
  local lktypes = {}
  local lkall = {}
  local lkcore = {}
  for _,v in ipairs(types.type) do
    if (v._attr.category == "struct") then
      local alias = v._attr.alias
      local name  = v._attr.name
      if (alias) then
        lktypes[name] = lktypes[alias]
      else
        local members = type(v.member[1]) == "table" and v.member or {v.member}
        local tab = {name=name, members=members} 
        if (members[1].type == "VkStructureType") then
          lktypes[name] = tab
          lkcore[name] = true
        end
        lkall[name] = tab
      end
    end
  end
  
  
  local platforms = {
    ggp = "VK_USE_PLATFORM_GGP",
    win32 = "VK_USE_PLATFORM_WIN32_KHR",
    vi = "VK_USE_PLATFORM_VI_NN",
    ios = "VK_USE_PLATFORM_IOS_MVK",
    macos = "VK_USE_PLATFORM_MACOS_MVK",
    android = "VK_USE_PLATFORM_ANDROID_KHR",
    fuchsia = "VK_USE_PLATFORM_FUCHSIA",
    metal = "VK_USE_PLATFORM_METAL_EXT",
    xlib = "VK_USE_PLATFORM_XLIB_KHR",
    xcb = "VK_USE_PLATFORM_XCB_KHR",
    wayland = "VK_USE_PLATFORM_WAYLAND_KHR",
    xlib_xrandr = "VK_USE_PLATFORM_XLIB_XRANDR_EXT",
  }
  
  -- fill extension list
  local extLists = {}
  
  for _,v in ipairs(extensions) do
    if (v.require) then
      local reqs = v.require[1] and v.require or {v.require}
      local list = {}
      local valid = false
      for _,r in ipairs(reqs) do
        if (r.type) then
          local types = r.type[1] and r.type or {r.type}
          for _,t in ipairs(types) do
            local tname = t._attr.name
            if (lktypes[tname]) then
              lkcore[tname] = false
              table.insert(list, tname)
              valid = true
            end
          end
        end
      end
      if (valid and ((whitelist and whitelist[v._attr.name]) or not whitelist))  then
        table.insert(extLists, {list=list, ext=v._attr.name, platform=platforms[v._attr.platform or "_"] })
      end
    end
  end
  
  -- fill core list
  local coreList = {}
  for _,v in ipairs(types.type) do
    if (v._attr.category == "struct" and lkcore[v._attr.name]) then
      table.insert(coreList, v._attr.name)
    end
  end
  
  local out = ""
  out = out.."  template <class T> T make(){ return T(); }\n"
  out = out.."  template <class T> void clear(T& ref){ ref = make<T>(); }\n"
  
  local function process(t)
    local ext = nil
    
    for _,sname in ipairs(t.list) do
      local enum   = structenums[enumID(sname:match("Vk(.*)"))]
      local struct = lktypes[sname]
      if (enum and struct and not struct.exported) then
        if ((not ext) and t.ext) then
          out = out.."#if "..t.ext.."\n"
          ext = t.ext
        end
        
        local complex = ""
        
        local function addComplex(prefix, members)
          for _,m in ipairs(members) do
            local mvar    = m.name
            local mtype   = m.type
            local mstruct = lkall[mtype]
            -- skip pointers
            if (mstruct and not m[1]) then
              local mexp     = mstruct.exported
              local mmembers = mstruct.members
              if (mexp == true) then
                complex = complex..prefix..mvar.." = make<"..mtype..">();\n"
              elseif (mexp) then
                complex = complex..prefix..mvar.." = {"..mexp.."};\n"
              elseif (mmembers) then
                addComplex(prefix..mvar..".", mmembers)
              end
            end
          end
        end      
        addComplex("    ret.", struct.members)
        
        
        if (override[sname]) then
          out = out..override[sname]
          print("override", sname)
          struct.exported = true
        elseif (complex ~= "") then
          out = out.."  template<> inline "..sname.." make<"..sname..">(){\n    "..sname.." ret = {"..enum.."};\n"..complex.."    return ret;\n  }\n"
          print("complex", sname)
          struct.exported = true
        else
          out = out.."  template<> inline "..sname.." make<"..sname..">(){\n    return "..sname.."{"..enum.."};\n  }\n"
          struct.exported = enum
        end
        
        
      end
    end
   
    if (ext) then
      out = out.."#endif\n"
    end
  end

  -- process core
  process({list=coreList})
  -- process whitelisted extensions
  for _,ext in ipairs(extLists) do
    process(ext)
  end
  
  local outfile = io.open(outfilename, "wt")
  assert(outfile, "could not open "..outfilename.." for writing")

  outfile:write("/* based on VK_HEADER_VERSION "..version.." */\n")
  outfile:write(header)
  outfile:write("namespace nvvk {\n")
  outfile:write(out)
  outfile:write("}\n")
  outfile:flush()
  outfile:close()
end

generate("structs_vk.hpp", header, extensionSubset)