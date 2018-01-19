import json
import rospy
import sys
import adc_reader
from std_msgs.msg import Float32


rospy.init_node('Analog_read_node', anonymous=False)
rate = rospy.Rate(200) #  200Hz
pub=rospy.Publisher('force_sns/ch0', Float32, queue_size=10)
adc_reader=adc_reader.ADC_Reader()
while not rospy.is_shutdown():
    pub.publish(adc_reader.read_ch(0))
    rate.sleep()