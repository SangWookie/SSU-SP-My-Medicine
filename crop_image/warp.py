from skimage.filters import threshold_local
import cv2
import numpy as np
import sys
import imutils

def order_points(pts):
    # initialzie a list of coordinates that will be ordered
    # such that the first entry in the list is the top-left,
    # the second entry is the top-right, the third is the
    # bottom-right, and the fourth is the bottom-left
    rect = np.zeros((4, 2), dtype = "float32")

    # the top-left point will have the smallest sum, whereas
    # the bottom-right point will have the largest sum
    s = pts.sum(axis = 1)
    rect[0] = pts[np.argmin(s)]
    rect[2] = pts[np.argmax(s)]

    # now, compute the difference between the points, the
    # top-right point will have the smallest difference,
    # whereas the bottom-left will have the largest difference
    diff = np.diff(pts, axis = 1)
    rect[1] = pts[np.argmin(diff)]
    rect[3] = pts[np.argmax(diff)]

    # return the ordered coordinates
    return rect

def four_point_transform(image, pts):
    # obtain a consistent order of the points and unpack them
    # individually
    rect = order_points(pts)
    (tl, tr, br, bl) = rect

    # compute the width of the new image, which will be the
    # maximum distance between bottom-right and bottom-left
    # x-coordiates or the top-right and top-left x-coordinates
    widthA = np.sqrt(((br[0] - bl[0]) ** 2) + ((br[1] - bl[1]) ** 2))
    widthB = np.sqrt(((tr[0] - tl[0]) ** 2) + ((tr[1] - tl[1]) ** 2))
    maxWidth = max(int(widthA), int(widthB))

    # compute the height of the new image, which will be the
    # maximum distance between the top-right and bottom-right
    # y-coordinates or the top-left and bottom-left y-coordinates
    heightA = np.sqrt(((tr[0] - br[0]) ** 2) + ((tr[1] - br[1]) ** 2))
    heightB = np.sqrt(((tl[0] - bl[0]) ** 2) + ((tl[1] - bl[1]) ** 2))
    maxHeight = max(int(heightA), int(heightB))

    # now that we have the dimensions of the new image, construct
    # the set of destination points to obtain a "birds eye view",
    # (i.e. top-down view) of the image, again specifying points
    # in the top-left, top-right, bottom-right, and bottom-left
    # order
    dst = np.array([
        [0, 0],
        [maxWidth - 1, 0],
        [maxWidth - 1, maxHeight - 1],
        [0, maxHeight - 1]], dtype = "float32")

    # compute the perspective transform matrix and then apply it
    M = cv2.getPerspectiveTransform(rect, dst)
    warped = cv2.warpPerspective(image, M, (maxWidth, maxHeight))

    # return the warped image
    return warped



file_name = int(sys.argv[1])
if len(sys.argv) != 2:
    print("Insufficient arguments")
    sys.exit()


image = cv2.imread('./img_resource/{}.jpg'.format(file_name))



ratio = image.shape[0] / 500
draw = image.copy()
image = imutils.resize(image, height = 500)

gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
blur = cv2.GaussianBlur(gray,(3,3),0)

v = np.median(blur)

sigma = 2.0

lower=int(max(0, (1.0-sigma)*v))
upper=int(max(0, (1.0+sigma)*v))

edge = cv2.Canny(blur, lower, upper)

kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (3,3))
closed = cv2.morphologyEx(edge, cv2.MORPH_CLOSE, kernel)

cnts = cv2.findContours(closed.copy(), cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
cnts = imutils.grab_contours(cnts)


cnts = sorted(cnts, key = cv2.contourArea, reverse = True) [:5]

screenCnt = cnts
for c in cnts:
    peri = cv2.arcLength(c, True)
    verticles = cv2.approxPolyDP(c, 0.02 * peri, True)
    if len(verticles) == 4:
        screenCnt = verticles
        break

if ((np.array_equal(screenCnt, verticles) == False)):
    contour = cnts[0]
    total = 0
    contours_xy = np.array(contour)
    contours_xy.shape
    
    x_min, x_max = 0,0
    value = list()
    for i in range(len(contours_xy)):
            value.append(contours_xy[i][0][0])
            x_min = min(value)
            x_max = max(value)

    y_min, y_max = 0,0
    value = list()
    for i in range(len(contours_xy)):
            value.append(contours_xy[i][0][1])
            y_min = min(value)
            y_max = max(value)

    x = x_min
    y = y_min
    w = x_max-x_min
    h = y_max-y_min
    contours_xy = np.array([[x,y],[x,h],[w,y],[w,h]])
    screenCnt = contours_xy

warped = four_point_transform(draw, screenCnt.reshape(4, 2) * ratio)

cv2.imwrite('./img_resource/{}.jpg'.format(file_name), warped)


