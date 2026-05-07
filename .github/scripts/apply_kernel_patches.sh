#!/bin/bash
set -e

# 进入内核源码目录（假设 working-directory 已经设为 kernel/）
cd "$GITHUB_WORKSPACE/kernel"  # 或者使用相对路径，根据实际调整

echo "Applying kernel patches..."

# 蓝牙
sed -i 's/#include <btfm_slim.h>/#include "btfm_slim.h"/' drivers/bluetooth/btfm_slim.c
sed -i 's/#include <btfm_slim_wcn3990.h>/#include "btfm_slim_wcn3990.h"/' drivers/bluetooth/btfm_slim_wcn3990.c

# trace 路径修复
sed -i 's|#define TRACE_INCLUDE_PATH .|#define TRACE_INCLUDE_PATH ../../drivers/clk/qcom/mdss|' drivers/clk/qcom/mdss/mdss_pll_trace.h
sed -i 's|#define TRACE_INCLUDE_PATH .|#define TRACE_INCLUDE_PATH ../../drivers/gpu/msm|' drivers/gpu/msm/kgsl_trace.h
sed -i 's|#define TRACE_INCLUDE_PATH .|#define TRACE_INCLUDE_PATH ../../drivers/gpu/msm|' drivers/gpu/msm/adreno_trace.h

# kgsl_device 包含
sed -i 's/#include <kgsl_device.h>/#include "kgsl_device.h"/' drivers/gpu/msm/kgsl_events.c


# 相机驱动：批量将尖括号包含改为双引号
find drivers/media/platform/msm/camera -type f \( -name "*.c" -o -name "*.h" \) -exec sed -i 's/#include <cam_/#include "cam_/g' {} \;

# 修复 cam_trace.h 中的路径
CAM_TRACE="drivers/media/platform/msm/camera/cam_utils/cam_trace.h"
sed -i 's|#include "cam_req_mgr_core.h"|#include "../cam_req_mgr/cam_req_mgr_core.h"|' "$CAM_TRACE"
sed -i 's|#include "cam_req_mgr_interface.h"|#include "../cam_req_mgr/cam_req_mgr_interface.h"|' "$CAM_TRACE"
sed -i 's|#include "cam_context.h"|#include "../cam_core/cam_context.h"|' "$CAM_TRACE"
sed -i 's|#define TRACE_INCLUDE_PATH .|#define TRACE_INCLUDE_PATH ../../drivers/media/platform/msm/camera/cam_utils|' "$CAM_TRACE"

# 修复 cam_isp_packet_parser.h
sed -i 's|#include "cam_ife_hw_mgr.h"|#include "../../cam_ife_hw_mgr.h"|' \
  drivers/media/platform/msm/camera/cam_isp/isp_hw_mgr/hw_utils/include/cam_isp_packet_parser.h

echo "All patches applied successfully."
