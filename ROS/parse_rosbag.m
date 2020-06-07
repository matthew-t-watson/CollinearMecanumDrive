

bag = rosbag('D:\Google_Drive\rosbags\2019-01-10-15-18-37.bag');

status = select(bag,'Topic','/robot/Status');

msgs = readMessages(status)