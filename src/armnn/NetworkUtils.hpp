//
// Copyright © 2017 Arm Ltd. All rights reserved.
// SPDX-License-Identifier: MIT
//

#pragma once

#include "DeviceSpec.hpp"
#include "Graph.hpp"
#include "SubGraph.hpp"

#include <backendsCommon/IBackendInternal.hpp>

namespace armnn
{

std::vector<ConvertFp16ToFp32Layer*> InsertConvertFp16ToFp32LayersBefore(Graph& graph, Layer& layer);

std::vector<ConvertFp32ToFp16Layer*> InsertConvertFp32ToFp16LayersAfter(Graph& graph, Layer& layer);

std::vector<DebugLayer*> InsertDebugLayerAfter(Graph& graph, Layer& layer);

PreCompiledLayer* CreatePreCompiledLayer(Graph& graph,
                                         const SubGraph& subGraph,
                                         unsigned int subGraphIndex,
                                         const IBackendInternalUniquePtr& backendObject);

} // namespace armnn
