# frozen_string_literal: true

require 'numo/narray'
require 'numo/pocketfft/version'
require 'numo/pocketfft/pocketfftext'

module Numo
  module Pocketfft
    module_function

    # Compute the 1-dimensional discrete Fourier Transform.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def fft(a)
      raw_fft(a, 0, inverse: false, real: false)
    end

    # Compute the 1-dimensional inverse discrete Fourier Transform.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def ifft(a)
      raw_fft(a, 0, inverse: true, real: false)
    end

    # Compute the 2-dimensional discrete Fourier Transform.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def fft2(a)
      fftn(a)
    end

    # Compute the 2-dimensional inverse discrete Fourier Transform.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def ifft2(a)
      ifftn(a)
    end

    # Compute the N-dimensional discrete Fourier Transform.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def fftn(a)
      raw_fftnd(a, inverse: false, real: false)
    end

    # Compute the N-dimensional inverse discrete Fourier Transform.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def ifftn(a)
      raw_fftnd(a, inverse: true, real: false)
    end

    # Compute the 1-dimensional discrete Fourier Transform for real input.
    # @param a [Numo::DFloat] input array
    # @return [Numo::DComplex]
    def rfft(a)
      raw_fft(a, 0, inverse: false, real: true)
    end

    # Compute the inverse of the 1-dimensional discrete Fourier Transform of real input.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def irfft(a)
      raw_fft(a, 0, inverse: true, real: true)
    end

    # Compute the 2-dimensional discrete Fourier Transform for real input.
    # @param a [Numo::DFloat] input array
    # @return [Numo::DComplex]
    def rfft2(a)
      rfftn(a)
    end

    # Compute the inverse of the 2-dimensional discrete Fourier Transform of real input.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def irfft2(a)
      irfftn(a)
    end

    # Compute the N-dimensional discrete Fourier Transform for real input.
    # @param a [Numo::DFloat] input array
    # @return [Numo::DComplex]
    def rfftn(a)
      last_axis_id = a.ndim - 1
      b = raw_fft(a, last_axis_id, inverse: false, real: true)
      (0...last_axis_id).to_a.reverse.each { |it| b = raw_fft(b, it, inverse: false, real: false) }
      b
    end

    # Compute the inverse of the N-dimensional discrete Fourier Transform of real input.
    # @param a [Numo::DComplex] input array
    # @return [Numo::DComplex]
    def irfftn(a)
      last_axis_id = a.ndim - 1
      b = a.dup
      (0...last_axis_id).to_a.each { |it| b = raw_fft(b, it, inverse: true, real: false) }
      raw_fft(b, last_axis_id, inverse: true, real: true)
    end

    # @!visibility private
    def raw_fft(a, axis_id, inverse:, real:)
      if axis_id == a.ndim - 1
        if real
          if inverse
            # zero padding
            n = (a.shape[-1] - 1) * 2
            b_shape = a.shape
            b_shape[-1] = n
            b = Numo::DComplex.zeros(*b_shape)
            b_range = [true] * b.ndim
            b_range[-1] = 0...a.shape[-1]
            b[*b_range] = a
            # inverse of dft for real data
            ext_irfft(b)
          else
            ext_rfft(a)
          end
        else
          if inverse
            ext_icfft(a)
          else
            ext_cfft(a)
          end
        end
      else
        if real
          if inverse
            ext_irfft(a.swapaxes(axis_id, -1)).swapaxes(axis_id, -1).dup
          else
            ext_rfft(a.swapaxes(axis_id, -1)).swapaxes(axis_id, -1).dup
          end
        else
          if inverse
            ext_icfft(a.swapaxes(axis_id, -1)).swapaxes(axis_id, -1).dup
          else
            ext_cfft(a.swapaxes(axis_id, -1)).swapaxes(axis_id, -1).dup
          end
        end
      end
    end

    # @!visibility private
    def raw_fftnd(a, inverse:, real:)
      b = a.dup
      (0...b.ndim).to_a.reverse.each { |it| b = raw_fft(b, it, inverse: inverse, real: real) }
      b
    end

    private_class_method :ext_cfft, :ext_icfft, :ext_rfft, :ext_irfft, :raw_fft, :raw_fftnd
  end
end