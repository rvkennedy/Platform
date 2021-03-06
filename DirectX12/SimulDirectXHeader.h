#pragma once
#include "ThisPlatform/Direct3D12.h"
//! Improves perfomance of CreateConstantBufferViews and CopyDescriptors
//! by removing a run time "if". This should only be on release builds...
#define D3DCOMPILE_NO_DEBUG 1 

#ifndef _XBOX_ONE
#ifndef _GAMING_XBOX
	#define SIMUL_DX12_SLOTS_CHECK
#endif
#endif

#include <DirectXMath.h>

#if defined(_XBOX_ONE) || defined(_GAMING_XBOX)
	#ifdef _GAMING_XBOX_SCARLETT
		#include "ThisPlatform/Direct3D12.h"
	#else
#ifndef _GAMING_XBOX //Deprecated from the GDK
	#include <D3Dcompiler_x.h>
#else
	#include <D3Dcompiler.h>
#endif
	#include <d3d12_x.h>		//! core 12.x header
	#include <d3dx12_x.h>		//! utility 12.x header
	#endif
//	#include <dxgi1_6.h>
	#define MONOLITHIC 1
	#define SIMUL_D3D11_MAP_USAGE_DEFAULT_PLACEMENT 1 
	#define SIMUL_D3D11_MAP_PLACEMENT_BUFFERS_CACHE_LINE_ALIGNMENT_PACK 1 
	#define SIMUL_D3D11_BUFFER_CACHE_LINE_SIZE 0x40 
#else
	#include <D3Dcompiler.h>
	#include <dxgi.h>
	#include <dxgi1_5.h>
	#include <d3d12.h>
	#include "d3dx12.h"
	#define SIMUL_D3D11_MAP_USAGE_DEFAULT_PLACEMENT 0 
#endif

#if defined(_XBOX_ONE) || defined(_GAMING_XBOX)
	#pragma comment(lib,"d3d12_x")
	#pragma comment(lib,"d3dcompiler")
#else
	#pragma comment(lib,"d3d12.lib")
	#pragma comment(lib,"D3dcompiler.lib")
	#pragma comment(lib,"DXGI.lib")
#endif 

#ifndef SAFE_RELEASE
	#define SAFE_RELEASE(p)			{ if(p) { (p)->Release(); (p)=nullptr; } }
#endif

#ifndef SAFE_RELEASE_LATER
#define SAFE_RELEASE_LATER(p)			{ if(p) {\
		auto renderPlatformDx12 = (dx12::RenderPlatform*)renderPlatform;\
		if(renderPlatformDx12)\
			renderPlatformDx12->PushToReleaseManager(p, #p);\
		else\
			p->Release();\
		p = nullptr;\
		 } }
#endif
#ifndef SAFE_RELEASE_ARRAY
	#define SAFE_RELEASE_ARRAY(p,n)	{ if(p) for(int i=0;i<n;i++) if(p[i]) { (p[i])->Release(); (p[i])=nullptr; } }
#endif
#ifndef SAFE_DELETE
    #define SAFE_DELETE(p)          { if(p) { delete p; p=nullptr;} }
#endif

#if defined(_XBOX_ONE) || defined(_GAMING_XBOX)
    #define  SIMUL_PPV_ARGS IID_GRAPHICS_PPV_ARGS
#else
    #define  SIMUL_PPV_ARGS IID_PPV_ARGS
#endif


