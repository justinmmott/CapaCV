import cv2

def take_picture(video_stream, out_file):
    for it in range(5):
        video_stream.read()
    ret, frame = video_stream.read()
    assert ret
    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2BGRA)
    saved = cv2.imwrite(out_file, rgb)
    assert saved
    video_stream.release()

if __name__ == '__main__':
    cap = cv2.VideoCapture(0)
    take_picture(cap, '../data/camera.jpg')
