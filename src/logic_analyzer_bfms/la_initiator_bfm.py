'''
Created on Nov 21, 2020

@author: mballance
'''

import pybfms

@pybfms.bfm(hdl={
    pybfms.BfmType.Verilog : pybfms.bfm_hdl_path(__file__, "hdl/la_initiator_bfm.v"),
    pybfms.BfmType.SystemVerilog : pybfms.bfm_hdl_path(__file__, "hdl/la_initiator_bfm.v"),
    }, has_init=True)
class LaInitiatorBfm():


    def __init__(self):
        self.busy = pybfms.lock()
        self.ack_ev = pybfms.event()
        self.width = 0
        self.reset_ev = pybfms.event()
        self.is_reset = False
        self.in_data = 0;
        
    async def set_bits(self, start, val, mask):
        await self.busy.acquire()
        
        if not self.is_reset:
            await self.reset_ev.wait()
            self.reset_ev.clear()
            
        self._set_bits(start, val, mask)
        
        self.busy.release()
        
    def data_in(self, start, nbits):
        pass
        
    async def set_oen(self, start, val, mask):
        await self.busy.acquire()
        
        self._set_oen(start, val, mask)
        
        self.busy.release()
        
        
    async def propagate(self):
        await self.busy.acquire()
        
        if not self.is_reset:
            await self.reset_ev.wait()
            self.reset_ev.clear()

        self._propagate_req()
        await self.ack_ev.wait()
        self.ack_ev.clear()
        self.busy.release()
        
    @pybfms.import_task(pybfms.uint32_t,pybfms.uint64_t,pybfms.uint64_t)
    def _set_bits(self, start, val, mask):
        pass
    
    @pybfms.import_task(pybfms.uint32_t,pybfms.uint64_t,pybfms.uint64_t)
    def _set_oen(self, start, val, mask):
        pass
        
    @pybfms.import_task()
    def _propagate_req(self):
        pass
    
    @pybfms.export_task()
    def _propagate_ack(self):
        self.ack_ev.set()
        
    @pybfms.export_task(pybfms.uint32_t, pybfms.uint32_t, pybfms.uint64_t)
    def _update_data_in(self, start, nbits, data):
        mask = ((1 << nbits) - 1) << start
        nmask = ((1 << self.width)-1) & ~mask
        self.in_data &= nmask
        self.in_data |= ((data & ((1 << nbits)-1)) << start);
    
    @pybfms.export_task(pybfms.uint32_t)
    def _set_parameters(self, width):
        self.width = width
        
    @pybfms.export_task()
    def _reset(self):
        self.is_reset = True
        self.reset_ev.set()
