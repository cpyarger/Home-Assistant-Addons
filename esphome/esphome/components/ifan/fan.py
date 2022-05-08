import esphome.codegen as cg
import esphome.config_validation as cv
from esphome.components import fan
from esphome.const import (
    CONF_OUTPUT_ID,
)

BUZZER_ENABLE = "buzzer_enable"

ifan_ns = cg.esphome_ns.namespace("ifan")

IFan = ifan_ns.class_("IFan", cg.Component, fan.Fan)

CONFIG_SCHEMA = fan.FAN_SCHEMA.extend(
    {
        cv.GenerateID(CONF_OUTPUT_ID): cv.declare_id(IFan),
        cv.Optional(BUZZER_ENABLE, default=True): cv.boolean,
    }
).extend(cv.COMPONENT_SCHEMA)


async def to_code(config):
    var = cg.new_Pvariable(config[CONF_OUTPUT_ID])
    cg.add(var.set_buzzer_enable(config[BUZZER_ENABLE]))
    await cg.register_component(var, config)

    await fan.register_fan(var, config)
