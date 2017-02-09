// Copyright (c) 2015 Simon Perkins
//
// This file is part of montblanc.
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, see <http://www.gnu.org/licenses/>.

#ifndef _MONTBLANC_KERNEL_TRAITS_CUH
#define _MONTBLANC_KERNEL_TRAITS_CUH

#include <cub/cub/cub.cuh>

namespace montblanc {

template <typename T> class kernel_traits
{
public:
	const static bool is_implemented = false;
};

template <typename T> class kernel_policies
{
public:
	const static bool is_implemented = false;
};

template <> class kernel_traits<float>
{
public:
	typedef float ft;
	typedef float2 ct;

public:
	const static bool is_implemented = true;
	const static float cuda_pi = CUDART_PI_F;
};

template <> class kernel_policies<float>
{
public:
	typedef kernel_traits<float> Tr;
    typedef kernel_policies<float> Po;

	__device__ __forceinline__ static
	Tr::ct make_ct(const Tr::ft & real, const Tr::ft & imag)
		{ return ::make_float2(real, imag); }

	__device__ __forceinline__ static
	Tr::ft sqrt(const Tr::ft & value)
		{ return ::sqrtf(value); }

	__device__ __forceinline__ static
	Tr::ft min(const Tr::ft & lhs, const Tr::ft & rhs)
		{ return ::fminf(lhs, rhs); }

	__device__ __forceinline__ static
	Tr::ft max(const Tr::ft & lhs, const Tr::ft & rhs)
		{ return ::fmaxf(lhs, rhs); }

	__device__ __forceinline__ static
	Tr::ft pow(const Tr::ft & value, const Tr::ft & exponent)
		{ return ::powf(value, exponent); }

	__device__ __forceinline__ static
	Tr::ft exp(const Tr::ft & value)
		{ return ::expf(value); }

	__device__ __forceinline__ static
	Tr::ft sin(const Tr::ft & value)
		{ return ::sinf(value); }

	__device__ __forceinline__ static
	Tr::ft cos(const Tr::ft & value)
		{ return ::cosf(value); }

	__device__ __forceinline__ static
	void sincos(const Tr::ft & value, Tr::ft * sinptr, Tr::ft * cosptr)
		{ ::sincosf(value, sinptr, cosptr); }

    __device__ __forceinline__ static
    Tr::ft atan2(const Tr::ft & y, const Tr::ft & x)
        { return ::atan2f(y, x); }

    __device__ __forceinline__ static
    Tr::ft arg(const Tr::ct & value)
        { return Po::atan2(value.y, value.x); }

    __device__ __forceinline__ static
    Tr::ft arg(const Tr::ft & value)
        { return Po::atan2(0.0f, value); }

    __device__ __forceinline__ static
    Tr::ft abs(const Tr::ct & value)
        { return Po::sqrt(value.x*value.x + value.y*value.y); }

    __device__ __forceinline__ static
    Tr::ft abs(const Tr::ft & value)
        { return ::fabsf(value); }

    __device__ __forceinline__ static
    Tr::ft round(const Tr::ft & value)
        { return ::roundf(value); }

    __device__ __forceinline__ static
    Tr::ft rint(const Tr::ft & value)
        { return ::rintf(value); }
};

template <>
class kernel_traits<double>
{
public:
	typedef double ft;
	typedef double2 ct;

public:
	const static bool is_implemented = true;
	const static double cuda_pi = CUDART_PI;
};

template <> class kernel_policies<double>
{
public:
	typedef kernel_traits<double> Tr;
    typedef kernel_policies<double> Po;

	__device__ __forceinline__ static
	Tr::ct make_ct(const Tr::ft & real, const Tr::ft & imag)
		{ return ::make_double2(real, imag); }

	__device__ __forceinline__ static
	Tr::ft sqrt(const Tr::ft & value)
		{ return ::sqrt(value); }

	__device__ __forceinline__ static
	Tr::ft min(const Tr::ft & lhs, const Tr::ft & rhs)
		{ return ::fmin(lhs, rhs); }

	__device__ __forceinline__ static
	Tr::ft max(const Tr::ft & lhs, const Tr::ft & rhs)
		{ return ::fmax(lhs, rhs); }

	__device__ __forceinline__ static
	Tr::ft pow(const Tr::ft & value, const Tr::ft & exponent)
		{ return ::pow(value, exponent); }

	__device__ __forceinline__ static
	Tr::ft exp(const Tr::ft & value)
		{ return ::exp(value); }

	__device__ __forceinline__ static
	Tr::ft sin(const Tr::ft & value)
		{ return ::sin(value); }

	__device__ __forceinline__ static
	Tr::ft cos(const Tr::ft & value)
		{ return ::cos(value); }

	__device__ __forceinline__ static
	void sincos(const Tr::ft & value, Tr::ft * sinptr, Tr::ft * cosptr)
		{ ::sincos(value, sinptr, cosptr); }

    __device__ __forceinline__ static
    Tr::ft atan2(const Tr::ft & y, const Tr::ft & x)
        { return ::atan2(y, x); }

    __device__ __forceinline__ static
    Tr::ft arg(const Tr::ct & value)
        { return Po::atan2(value.y, value.x); }

    __device__ __forceinline__ static
    Tr::ft arg(const Tr::ft & value)
        { return Po::atan2(0.0, value); }

    __device__ __forceinline__ static
    Tr::ft abs(const Tr::ct & value)
        { return Po::sqrt(value.x*value.x + value.y*value.y); }

    __device__ __forceinline__ static
    Tr::ft abs(const Tr::ft & value)
        { return ::abs(value); }

    __device__ __forceinline__ static
    Tr::ft round(const Tr::ft & value)
        { return ::round(value); }

    __device__ __forceinline__ static
    Tr::ft rint(const Tr::ft & value)
        { return ::rint(value); }
};

template <
    typename T,
    typename Tr=kernel_traits<T>,
    typename Po=kernel_policies<T> >
__device__ __forceinline__ void complex_multiply(
    typename Tr::ct & result,
    const typename Tr::ct & lhs,
    const typename Tr::ct & rhs)
{
    // (a+bi)(c+di) = (ac-bd) + (ad+bc)i
    // a = lhs.x b=lhs.y c=rhs.x d = rhs.y
    result.x = lhs.x*rhs.x - lhs.y*rhs.y;
    result.y = lhs.x*rhs.y + lhs.y*rhs.x;
}

template <
    typename T,
    typename Tr=kernel_traits<T>,
    typename Po=kernel_policies<T> >
__device__ __forceinline__ void complex_multiply_in_place(
    typename Tr::ct & lhs,
    const typename Tr::ct & rhs)
{
    typename Tr::ft tmp = lhs.x;

    lhs.x *= rhs.x;
    lhs.x -= lhs.y*rhs.y;
    lhs.y *= rhs.x;
    lhs.y += tmp*rhs.y;
}

} // namespace montblanc

#endif // _MONTBLANC_KERNEL_TRAITS_CUH
