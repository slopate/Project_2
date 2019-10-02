import serial

#port = "/dev/ttyUSB0"
port = "/dev/cu.SLAB_USBtoUART"

s1 = serial.Serial(port, 9600)
s1.flushInput()
string1 = ""


while True:
	if s1.inWaiting()>0:
		inputValue = s1.readline()
		print(inputValue)
		# if str(inputValue) == b'\n':
		# 	print(string1)
		# 	string1=""		
		# else:
		# 	string1.join(str(inputValue))
