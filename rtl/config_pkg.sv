
package config_pkg;

// define structs and enums needed for design
typedef enum logic [3:0] {
    idle,
    size,
    load,
    sort,
    transmit_left_bracket,
    bram_read,  //using sync mem requies the extra state
    bram_data_valid, //sync data is only valid for one cycle after ir being read
    transmit_raw_int,
    transmit_comma,
    transmit_right_bracket,
    error
} state_t;

endpackage
