require 'ffi'

module VagrantPlugins
  module ProviderVMwareFree
    module Driver

      module VIX
        class VIXError < StandardError; end
        extend FFI::Library

        if /darwin/ =~ RUBY_PLATFORM
                ffi_lib '/Applications/VMware Fusion.app/Contents/Public/libvixAllProducts.dylib'
        elsif /cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM
                ffi_lib 'c:/Program Files (x86)/VMware/VMware VIX/VixAllProductsDyn.dll'
        else
                ffi_lib '/usr/lib/vmware-vix/libvixAllProducts.so'
        end

      end
    end
  end
end

require_relative('vix/types')
require_relative('vix/functions')
require_relative('vix/helpers')
