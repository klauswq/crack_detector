import json
import rospy
import sys
import time
import RPi.GPIO as GPIO
from std_msgs.msg import Float32
from geometry_msgs.msg import Point


class Servo_node:
    def __init__(self):
        rospy.init_node('servo_node', anonymous=False)
        GPIO.setwarnings(False)
        GPIO.setmode(GPIO.BCM)
        # Setting up for pin 12. Y-axis
        GPIO.setup(12, GPIO.OUT)
        # Setting up for pin 13. X-axis
        GPIO.setup(13, GPIO.OUT)
        GPIO.setup(20, GPIO.OUT)
        self.pwm_y = GPIO.PWM(12, 50)
        self.pwm_y.start(3)
        self.pwm_x = GPIO.PWM(13, 50)
        self.pwm_x.start(12.5)
        self.pwm_z = GPIO.PWM(20, 50)
        self.pwm_z.start(12.5)
        self.sub = rospy.Subscriber("servo_control", Point, self.set_servo_angle)

    def set_servo_angle(self, msg):
        rospy.loginfo("setting servo")
        pw_x = -1.4147 * msg.x + 12.5
        pw_y = 1.4147 * msg.y + 5
        pw_z = -1 * msg.z + 12.5
        self.pwm_y.ChangeDutyCycle(pw_y)  # Note tha this does not correspond to angle
        time.sleep(.1)

        self.pwm_x.ChangeDutyCycle(pw_x)  # Note tha this does not correspond to angle
        time.sleep(.1)

        self.pwm_z.ChangeDutyCycle(pw_z)  # Note tha this does not correspond to angle
        time.sleep(.1)

    def saturate_input(self, a):
        return max(min(a, 100), 0)


def main_loop():
    rate = rospy.Rate(10)  # 10Hz
    while not rospy.is_shutdown():
        rate.sleep()


if __name__ == "__main__":
    servo = Servo_node()
    main_loop()
