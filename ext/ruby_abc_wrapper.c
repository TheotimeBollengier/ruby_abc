#include "base/main/main.h"
#include "misc/util/utilCex.h"
#include "ruby_abc_wrapper.h"

    
int rubyabc_c_n_ands()
{
    Abc_Frame_t* pAbc = Abc_FrameGetGlobalFrame();
    Abc_Ntk_t * pNtk = Abc_FrameReadNtk(pAbc);

    if (pNtk && Abc_NtkIsStrash(pNtk))
        return Abc_NtkNodeNum(pNtk);

    return -1;
}
    

int rubyabc_c_n_nodes()
{
    Abc_Frame_t* pAbc = Abc_FrameGetGlobalFrame();
    Abc_Ntk_t * pNtk = Abc_FrameReadNtk(pAbc);

    if (pNtk)
        return Abc_NtkNodeNum(pNtk);

    return -1;
}


int rubyabc_c_n_pis()
{
    Abc_Frame_t* pAbc = Abc_FrameGetGlobalFrame();
    Abc_Ntk_t * pNtk = Abc_FrameReadNtk(pAbc);

    if (pNtk)
        return Abc_NtkPiNum(pNtk);

    return -1;
}


int rubyabc_c_n_pos()
{
    Abc_Frame_t* pAbc = Abc_FrameGetGlobalFrame();
    Abc_Ntk_t * pNtk = Abc_FrameReadNtk(pAbc);

    if (pNtk)
        return Abc_NtkPoNum(pNtk);

    return -1;
}


int rubyabc_c_n_latches()
{
    Abc_Frame_t* pAbc = Abc_FrameGetGlobalFrame();
    Abc_Ntk_t * pNtk = Abc_FrameReadNtk(pAbc);

    if (pNtk)
        return Abc_NtkLatchNum(pNtk);

    return -1;
}


int rubyabc_c_n_levels()
{
    Abc_Frame_t* pAbc = Abc_FrameGetGlobalFrame();
    Abc_Ntk_t * pNtk = Abc_FrameReadNtk(pAbc);

    if (pNtk)
        return Abc_NtkLevel(pNtk);

    return -1;
}


int rubyabc_c_run_command(const char* cmd)
{
    Abc_Frame_t* pAbc = Abc_FrameGetGlobalFrame();
    
    return Cmd_CommandExecute(pAbc, cmd);
}


void rubyabc_c_start(void)
{
	Abc_Start();
}

