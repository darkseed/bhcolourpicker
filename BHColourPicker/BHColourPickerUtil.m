//
//  Util.m
//  ColourPickerHarness
//
//  Created by bunnyhero on 03/05/09.
/*
 Copyright (c) 2009, BUNNYHERO LABS
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice,
   this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
 * Neither the name of BUNNYHERO LABS nor the names of its contributors
   may be used to endorse or promote products derived from this software
   without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE. 
*/

#import "BHColourPickerUtil.h"

static float my_mod(float x, float y) { return x - y * floor(x / y); }

static float my_min(float x, float y, float z)
{
    return x < y ? ( x < z ? x : z ) : ( y < z ? y : z );
}

static float my_max(float x, float y, float z)
{
    return x > y ? ( x > z ? x : z ) : ( y > z ? y : z );
}

@implementation BHColourPickerUtil

+ (RedGreenBlue)redGreenBlueFromHueSaturationValue:(HueSaturationValue)hueSaturationValue
{
    float h = hueSaturationValue.hue;
    float s = hueSaturationValue.saturation;
    float v = hueSaturationValue.value;
    
    int i;

    float f, p, q, t;
    
    RedGreenBlue result;
    
    if (fabs(s) < 1.0E-4) {
        // achromatic (grey)
        result.red = result.blue = result.green = v;
        return result;
    }

    // hue has to be from 0 to 360, positive.
    h = my_mod(h, 360.f);
    h /= 60.f;            // sector 0 to 5
    i = floor( h );
    f = h - i;          // fractional part of h
    p = v * ( 1 - s );
    q = v * ( 1 - s * f );
    t = v * ( 1 - s * ( 1 - f ) );
    
    float r, g, b;
    
    switch( i ) {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        default:        // case 5:
            r = v;
            g = p;
            b = q;
            break;
    }
    result.red = r;
    result.green = g;
    result.blue = b;
    return result;
}



+ (HueSaturationValue)hueSaturationValueFromRedGreenBlue:(RedGreenBlue)redGreenBlue
{
    float r = redGreenBlue.red;
    float g = redGreenBlue.green;
    float b = redGreenBlue.blue;
    HueSaturationValue hsv;
    float *h = &hsv.hue;
    float *s = &hsv.saturation;
    float *v = &hsv.value;
    
	float min, max, delta;
    
	min = my_min( r, g, b );
	max = my_max( r, g, b );
	*v = max;				// v
    
	delta = max - min;
    
	if( max != 0 )
		*s = delta / max;		// s
	else {
		// r = g = b = 0		// s = 0, v is undefined
		*s = 0;
		*h = 0;
		return hsv;
	}
    
    if (delta != 0) {
        if( r == max )
            *h = ( g - b ) / delta;		// between yellow & magenta
        else if( g == max )
            *h = 2 + ( b - r ) / delta;	// between cyan & yellow
        else
            *h = 4 + ( r - g ) / delta;	// between magenta & cyan
    }
    else {
        //  undefined, really. so it doesn't matter:
        *h = 0;
    }
    
	*h *= 60;				// degrees
	if( *h < 0 )
		*h += 360;

    return hsv;
}

@end
