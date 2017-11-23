#ifndef RUBYABC_WRAPPER_H_INCLUDED
#define RUBYABC_WRAPPER_H_INCLUDED

void rubyabc_c_start(void);
int  rubyabc_c_run_command(const char* cmd);
int  rubyabc_c_n_ands();
int  rubyabc_c_n_nodes();
int  rubyabc_c_n_pis();
int  rubyabc_c_n_pos();
int  rubyabc_c_n_latches();
int  rubyabc_c_n_levels();

#endif /* RUBYABC_WRAPPER_H_INCLUDED */
