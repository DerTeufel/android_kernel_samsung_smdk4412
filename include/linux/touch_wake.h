/* include/linux/touch_wake.h */

#ifndef _LINUX_TOUCH_WAKE_H
#define _LINUX_TOUCH_WAKE_H

#include <linux/input.h>

/*void powerkey_pressed(void);
void powerkey_released(void);*/
void proximity_detected(void);
void proximity_off(void);
void touch_press(void);
//bool get_s2w_status(void);
//bool device_is_suspended(void);
void set_powerkeydev(struct input_dev * input_device);
void set_touch_wake_enabled(bool touchwake_enabled);
void mms152_ts_gpio_sleep_mode(bool touchwake_enabled);
void set_s2w_enabled(bool s2w_enabled);

#endif
