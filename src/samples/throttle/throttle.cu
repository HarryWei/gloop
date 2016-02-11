/*
  Copyright (C) 2016 Yusuke Suzuki <yusuke.suzuki@sslab.ics.keio.ac.jp>

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
  ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

#include <gloop/gloop.h>

__device__ void throttle(gloop::DeviceLoop* loop, int count, int limit)
{
    if (count != limit) {
        gloop::loop::async(loop, [=] (gloop::DeviceLoop* loop) {
            throttle(loop, count + 1, limit);
        });
    }
}

int main(int argc, char** argv) {

    if(argc<4) {
        fprintf(stderr,"<kernel_iterations> <blocks> <threads>\n");
        return -1;
    }
    int trials=atoi(argv[1]);
    int nblocks=atoi(argv[2]);
    int nthreads=atoi(argv[3]);

    fprintf(stderr," iterations: %d blocks %d threads %d\n",trials, nblocks, nthreads);

    {
        uint32_t pipelinePageCount = 0;
        dim3 blocks(nblocks);
        std::unique_ptr<gloop::HostLoop> hostLoop = gloop::HostLoop::create(0);
        std::unique_ptr<gloop::HostContext> hostContext = gloop::HostContext::create(*hostLoop, blocks, pipelinePageCount);

        CUDA_SAFE_CALL(cudaDeviceSetLimit(cudaLimitMallocHeapSize, (1ULL << 20)));

        hostLoop->launch(*hostContext, nthreads, [=] GLOOP_DEVICE_LAMBDA (gloop::DeviceLoop* loop, thrust::tuple<int> tuple) {
            throttle(loop, 0, thrust::get<0>(tuple));
        }, trials);
    }

    return 0;
}