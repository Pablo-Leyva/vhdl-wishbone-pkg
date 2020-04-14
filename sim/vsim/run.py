# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this file,
# You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2014-2019, Lars Asplund lars.anders.asplund@gmail.com

from os.path import join, dirname
from vunit import VUnit
from itertools import product

root = dirname(__file__)

ui = VUnit.from_argv()
ui.add_random()
ui.add_verification_components()
lib = ui.library("vunit_lib")

#Include libraries
lib.add_source_files(join(root, "../../../vhdl-utils/rtl/", "*.vhd"))

#Include Sources
lib.add_source_files(join(root, "../../rtl", "*.vhd"))

#Include Testbench
lib.add_source_files(join(root, "tb", "tb_wb3_cdc_sync.vhd"))

def encode(tb_cfg):
    return ",".join(["%s:%s" % (key, str(tb_cfg[key])) for key in tb_cfg])

#def gen_axis_width_converter(obj, *args):
#    for s_axis_tdata_width, m_axis_tdata_width, packet_number in product(*args):
#        tb_cfg = dict(
#            s_axis_tdata_width=s_axis_tdata_width,
#            m_axis_tdata_width=m_axis_tdata_width,
#            packet_number=packet_number)
#        config_name = encode(tb_cfg)
#        obj.add_config(name=config_name,
#                       generics=dict(encoded_tb_cfg=encode(tb_cfg)))

#tb_axis_width_converter = lib.test_bench("tb_axis_width_converter")
#for test in tb_axis_width_converter.get_tests():
#    gen_axis_width_converter(test, range(8,128,8), range(8,128,8), [32])

ui.main()
