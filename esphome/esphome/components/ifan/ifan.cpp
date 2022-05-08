#include "ifan.h"
#include "esphome/components/fan/fan_helpers.h"
#include "esphome/core/log.h"
#include "esphome.h"
#include "light.h"
namespace esphome {
namespace ifan {
#define buzzer 10
#define relay_1 14
#define relay_2 12
#define relay_3 15
static const char *const TAG = "ifan.fan";
int target_fan_speed;
int start_time_offset;
void IFan::setup() {
  pinMode(buzzer, 0x01);
  pinMode(relay_1, 0x01);
  pinMode(relay_2, 0x01);
  pinMode(relay_3, 0x01);

  auto restore = this->restore_state_();
  if (restore.has_value()) {
    restore->apply(*this);
    this->current_speed = this->speed;
    this->write_state_();
  }
}
void IFan::dump_config() { LOG_FAN("", "IFan", this); }
fan::FanTraits IFan::get_traits() { return fan::FanTraits(false, true, false, 100); }
void IFan::control(const fan::FanCall &call) {
  if (call.get_state().has_value())
    this->state = *call.get_state();
  if (call.get_speed().has_value())
    this->speed = *call.get_speed();

  this->write_state_();
  this->publish_state();
}
void IFan::write_state_() {
  int local_speed = static_cast<int>(this->speed);
  ESP_LOGD("IFAN", "Setting Fan Speed %i", local_speed);
  ESP_LOGD("IFAN", "State is %s", this->state ? "ON" : "OFF");
  if (!this->state)
    set_off();
  if (this->state)
    do_speed(local_speed);
}  // write_state_

void IFan::do_speed(const int lspeed){
    switch (lspeed) {
      case 1 ... 33:
         // low speed
        set_low();
        break;
      case 34 ... 66:
        // medium speed
        set_med();
        break;
      case 67 ... 100:
          // high speed
        set_high();
        break;

      default:
        set_off();
        break;
    }

}
void IFan::set_off() {
  ESP_LOGD("IFAN", "Setting Fan OFF");
  this->state = 0;
  digitalWrite(relay_1, LOW);
  digitalWrite(relay_2, LOW);
  digitalWrite(relay_3, LOW);
  long_beep();
}
void IFan::set_low() {
  ESP_LOGD("IFAN", "Setting Fan Low");
  digitalWrite(relay_1, HIGH);
  digitalWrite(relay_2, LOW);
  digitalWrite(relay_3, LOW);
  beep();
}
void IFan::set_med() {
  ESP_LOGD("IFAN", "Setting Fan Med");
  digitalWrite(relay_1, LOW);
  digitalWrite(relay_2, HIGH);
  digitalWrite(relay_3, LOW);
  beep(2);
}
void IFan::set_high() {
  ESP_LOGD("IFAN", "Setting Fan HIGH");
  digitalWrite(relay_1, LOW);
  digitalWrite(relay_2, LOW);
  digitalWrite(relay_3, HIGH);

  beep(3);
}
void IFan::set_buzzer_enable(bool buzzer_enable) { this->buzzer_enable_ = buzzer_enable; }
void IFan::beep(int num) {
  if (!this->buzzer_enable_)
    return;
  for (int i = 0; i < num; i++) {
    digitalWrite(buzzer, LOW);
    delay(50);
    digitalWrite(buzzer, HIGH);
    delay(50);
  }
}
void IFan::long_beep(int num) {
  if (!this->buzzer_enable_)
    return;
  for (int i = 0; i < num; i++) {
    ESP_LOGD("IFAN", "Long Beep");
    digitalWrite(buzzer, LOW);
    delay(500);
    digitalWrite(buzzer, HIGH);
    delay(500);
  }
}

}  // namespace ifan

}  // namespace esphome
