#include <leaf/LeafApp.hpp>

namespace leaf
{
    void LeafApp::Run()
    {
        m_App.port(18080).multithreaded().run();
    }
}
