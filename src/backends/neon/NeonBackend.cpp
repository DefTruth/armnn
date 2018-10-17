//
// Copyright © 2017 Arm Ltd. All rights reserved.
// SPDX-License-Identifier: MIT
//

#include "NeonBackend.hpp"
#include "NeonBackendId.hpp"
#include "NeonWorkloadFactory.hpp"

#include <backends/BackendRegistry.hpp>

#include <boost/cast.hpp>

namespace armnn
{

namespace
{

static StaticRegistryInitializer<BackendRegistry> g_RegisterHelper
{
    BackendRegistryInstance(),
    NeonBackend::GetIdStatic(),
    []()
    {
        return IBackendUniquePtr(new NeonBackend, &NeonBackend::Destroy);
    }
};

}

const BackendId& NeonBackend::GetIdStatic()
{
    static const BackendId s_Id{NeonBackendId()};
    return s_Id;
}

std::unique_ptr<IWorkloadFactory> NeonBackend::CreateWorkloadFactory() const
{
    return std::make_unique<NeonWorkloadFactory>();
}

void NeonBackend::Destroy(IBackend* backend)
{
    delete boost::polymorphic_downcast<NeonBackend*>(backend);
}

} // namespace armnn