package config_pkg;

typedef enum logic [2:0] {
    INIT,
    PC_activ,
    MR,
    BA,
    READ,
    WRITE,
    PC_deactiv,
    SR
} state_t;

endpackage
