#pragma once

#include "esphome/core/component.h"
#include "esphome/components/output/binary_output.h"
#include "esphome/components/light/light_output.h"
#include "esphome.h"

namespace esphome {
namespace ifan {

class IFanLight : public light::LightOutput {
 public:
  light::LightTraits get_traits() override {
    auto traits = light::LightTraits();
    traits.set_supported_color_modes({light::ColorMode::ON_OFF});
    return traits;
  }
  virtual void setup_state(light::LightState *state) {
    state_ = state;
  }

  void write_state(light::LightState *state) override {
    bool binary;
    state->current_values_as_binary(&binary);
    if (binary)
      digitalWrite(9, LOW);
    else
      digitalWrite(9, HIGH);
  }
  void toggle_light(){
    this->
  }
 protected:
  light::LightState *state_;
  bool test = false;
};  // class
}  // namespace ifan
}  // namespace esphome
