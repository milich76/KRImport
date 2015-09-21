/******************************************************************************

 @File         PVRTextureFormat.h

 @Title        

 @Version       @Version      

 @Copyright    Copyright (c) Imagination Technologies Limited.

 @Platform     

 @Description  

******************************************************************************/
#ifndef _PVRT_PIXEL_FORMAT_H
#define _PVRT_PIXEL_FORMAT_H

#include "PVRTextureDefines.h"
#include "PVRTString.h"
namespace pvrtexture
{
	//Channel Names
	enum EChannelName
	{
		eNoChannel,
		eRed,
		eGreen,
		eBlue,
		eAlpha,
		eLuminance,
		eIntensity,
		eUnspecified,
		eNumChannels
	};

	//PixelType union
	union PixelType
	{
		PixelType();
		PixelType(uint64 Type);
		PixelType(uint8 C1Name, uint8 C2Name, uint8 C3Name, uint8 C4Name, uint8 C1Bits, uint8 C2Bits, uint8 C3Bits, uint8 C4Bits);

		struct LowHigh
		{
			uint32	Low;
			uint32	High;
		} Part;

		uint64	PixelTypeID;
		uint8	PixelTypeChar[8];
	};

	static const PixelType PVRStandard8PixelType = PixelType('r','g','b','a',8,8,8,8);
	static const PixelType PVRStandard16PixelType = PixelType('r','g','b','a',16,16,16,16);
	static const PixelType PVRStandard32PixelType = PixelType('r','g','b','a',32,32,32,32);
}

#endif


