#!/usr/bin/env ruby -wKU

module JEdI
  class Opcode
    attr_reader :r1

    def execute(vm)
      send(self.class.const_get(:OPS)[@op], vm)
    end

    private

    def read(opcode, pattern)
      ("%032b" % opcode.unpack("V")).unpack(pattern).map { |n| n.to_i(2) }
    end
  end

  class DTypeOpcode < Opcode
    OPS = [nil] + %w[add sub mult div output phi]

    def initialize(opcode)
      @op, @r1, @r2 = read(opcode, "a4a14a14")
      raise "Unexpected DType OP %p (%p)" % [@op, opcode] \
        if not @op.between? 1, 6
    end

    attr_reader :r2

    private

    def add(vm)
      vm.data[@r1] + vm.data[@r2]
    end

    def sub(vm)
      vm.data[@r1] - vm.data[@r2]
    end

    def mult(vm)
      vm.data[@r1] * vm.data[@r2]
    end

    def div(vm)
      return 0.0 if vm.data[@r2] == 0.0
      vm.data[@r1] / vm.data[@r2]
    end

    def output(vm)
      vm.write_output(@r1, vm.data[@r2])
      nil  # don't update data
    end

    def phi(vm)
      vm.data[vm.status? ? @r1 : @r2]
    end
  end

  class STypeOpcode < Opcode
    OPS  = %w[noop cmpz sqrt copy input]
    IMMS = %w[< <= == >= >]

    def initialize(opcode)
      @op, @imm, @r1 = read(opcode, "x4a4a3x7a14")
      raise "Unexpected SType OP %p (%p)"  % [@op,  opcode] if @op > 4
      raise "Unexpected SType IMM %p (%p)" % [@imm, opcode] \
        if @op == 1 and @imm > 4
    end

    private

    def noop(vm)
      nil  # don't update data
    end

    def cmpz(vm)
      vm.status = vm.data[@r1].send(IMMS[@imm], 0.0)
      nil  # don't update data
    end

    def sqrt(vm)
      Math.sqrt(vm.data[@r1].abs)
    end

    def copy(vm)
      vm.data[@r1]
    end

    def input(vm)
      vm.input_ports[@r1]
    end
  end
end
