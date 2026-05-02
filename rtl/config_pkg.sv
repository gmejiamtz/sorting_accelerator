
package config_pkg;

// define structs and enums needed for design
typedef enum logic [3:0] {
    idle,
    size,
    load,
    sort,
    transmit_left_bracket,
    transmit_raw_int,
    transmit_comma,
    transmit_right_bracket,
    error
} state_t;

endpackage
