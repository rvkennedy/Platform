#include "PlatformConstantBuffer.h"
#include "RenderPlatform.h"

using namespace simul;
using namespace vulkan;


PlatformConstantBuffer::PlatformConstantBuffer():
			mSlots(0)
			,mMaxDescriptors(0)
			,mLastFrameIndex(0)
			,mCurApplyCount(0)
			,src(0)
			,size(0)
	,last_offset(0)
	,lastBuffer(nullptr)
{
}

PlatformConstantBuffer::~PlatformConstantBuffer()
{
    InvalidateDeviceObjects();
}

void PlatformConstantBuffer::RestoreDeviceObjects(crossplatform::RenderPlatform* r,size_t sz,void *addr)
{
	renderPlatform=r;
	SIMUL_ASSERT(sz<=mBufferSize);
	mSlots = ((sz + (kBufferAlign - 1)) & ~ (kBufferAlign - 1)) / kBufferAlign;
	SIMUL_ASSERT(mSlots>0);
	mMaxDescriptors = mBufferSize / (kBufferAlign * mSlots);
	vk::BufferCreateInfo buf_info = vk::BufferCreateInfo()
		.setSize(mBufferSize)
		.setUsage(vk::BufferUsageFlagBits::eUniformBuffer)
		.setSharingMode(vk::SharingMode::eExclusive);
	vk::Device *vulkanDevice=renderPlatform->AsVulkanDevice();
	for (unsigned int i = 0; i < kNumBuffers; i++)
	{
		auto result = vulkanDevice->createBuffer(&buf_info, nullptr, &mBuffers[i]);
		SIMUL_ASSERT(result == vk::Result::eSuccess);
		SetVulkanName(renderPlatform,&(mBuffers[i]),"Pipeline layout");

		vk::MemoryRequirements mem_reqs;
		vulkanDevice->getBufferMemoryRequirements(mBuffers[i], &mem_reqs);

		auto mem_alloc = vk::MemoryAllocateInfo().setAllocationSize(mem_reqs.size).setMemoryTypeIndex(0);

		bool  pass = ((vulkan::RenderPlatform*)renderPlatform)->memory_type_from_properties(
			mem_reqs.memoryTypeBits, vk::MemoryPropertyFlagBits::eHostVisible | vk::MemoryPropertyFlagBits::eHostCoherent,
			&mem_alloc.memoryTypeIndex);
		SIMUL_ASSERT(pass);

		result = vulkanDevice->allocateMemory(&mem_alloc, nullptr, &mMemory[i]);
		SIMUL_ASSERT(result == vk::Result::eSuccess);
		SetVulkanName(renderPlatform,&(mMemory[i]),"cb memory");
		if(addr)
		{
			auto pData = vulkanDevice->mapMemory(mMemory[i], 0, VK_WHOLE_SIZE, vk::MemoryMapFlags());
			SIMUL_ASSERT(pData!=nullptr);

			memcpy(pData, addr, sz);

			vulkanDevice->unmapMemory(mMemory[i]);
		}

		vulkanDevice->bindBufferMemory(mBuffers[i], mMemory[i], 0);
		SIMUL_ASSERT(result == vk::Result::eSuccess);
	}

	// Create the "Descriptor Pool":
	//vk::DescriptorPoolSize const poolSizes[1] =
	//	{
	//		vk::DescriptorPoolSize().setType(vk::DescriptorType::eUniformBuffer).setDescriptorCount(kNumBuffers)
	//	};

	//auto const descriptor_pool =
	//	vk::DescriptorPoolCreateInfo().setMaxSets(kNumBuffers).setPoolSizeCount(1).setPPoolSizes(poolSizes);

	//auto result = vulkanDevice->createDescriptorPool(&descriptor_pool, nullptr, &mDescriptorPool);
	//	SetVulkanName(renderPlatform,&(mDescriptorPool),"cb mDescriptorPool");
	lastBuffer=nullptr;
	last_offset=0;
	src=0;
	size=sz;
	last_offset=0;
	//SIMUL_ASSERT(result == vk::Result::eSuccess);

}

void PlatformConstantBuffer::InvalidateDeviceObjects()
{
	if(!renderPlatform)
		return;
	vk::Device *vulkanDevice=renderPlatform->AsVulkanDevice();
	if(!vulkanDevice)
		return;
	for (uint32_t i = 0; i < kNumBuffers; i++)
	{
		vulkanDevice->destroyBuffer(mBuffers[i], nullptr);
		vulkanDevice->freeMemory(mMemory[i], nullptr);
	}
	//vulkanDevice->destroyDescriptorPool(mDescriptorPool, nullptr);
	//vulkanDevice->destroyDescriptorSetLayout(mDescLayout, nullptr);
	renderPlatform=nullptr;
}

void PlatformConstantBuffer::LinkToEffect(crossplatform::Effect* effect,const char* name,int bindingIndex)
{
	std::string mName=name;
	for (unsigned int i = 0; i < kNumBuffers; i++)
	{
	//	mBuffers[i].setName(name);
	}
}

void PlatformConstantBuffer::Apply(simul::crossplatform::DeviceContext& deviceContext,size_t sz,void* addr)
{
	src=addr;
	size=sz;
}

void PlatformConstantBuffer::ActualApply(crossplatform::DeviceContext &deviceContext,crossplatform::EffectPass *,int) 
{
	if(!src)
		return;
	vk::Device *vulkanDevice=renderPlatform->AsVulkanDevice();
	if (mCurApplyCount >= mMaxDescriptors)
	{
		// This should really be solved by having like some kind of pool? Or allocating more space, something like that
		SIMUL_BREAK_ONCE("This ConstantBuffer reached its maximum apply count");
		return;
	}

	auto rPlat = (vulkan::RenderPlatform*)renderPlatform;
	auto curFrameIndex = rPlat->GetIdx();
	// If new frame, update current frame index and reset the apply count
	if (mLastFrameIndex != curFrameIndex)
	{
		mLastFrameIndex = curFrameIndex;
		mCurApplyCount = 0;
	}

	// pDest points at the begining of the uploadHeap, we can offset it! (we created 64KB and each Constart buffer
	// has a minimum size of kBufferAlign)
	uint8_t* pDest = nullptr;
	last_offset = (kBufferAlign * mSlots) * mCurApplyCount;	
	lastBuffer=&mBuffers[curFrameIndex];

	auto pData = vulkanDevice->mapMemory(mMemory[curFrameIndex],last_offset, (kBufferAlign * mSlots),  vk::MemoryMapFlags());
	
	if(pData)
	{
		memcpy(pData,src, size);
		//memset(pData,255,size);
		vulkanDevice->unmapMemory(mMemory[curFrameIndex]);
	}
	
	mCurApplyCount++;
	src=0;
}

size_t PlatformConstantBuffer::GetLastOffset()
{
	return last_offset;
}

vk::Buffer *PlatformConstantBuffer::GetLastBuffer()
{
	return lastBuffer;
}

size_t PlatformConstantBuffer::GetSize()
{
	return size;
}

void PlatformConstantBuffer::Unbind(simul::crossplatform::DeviceContext& deviceContext)
{
}
