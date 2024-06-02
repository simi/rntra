import cv2
import sys
import numpy as np

def print_progress_bar(text, iteration, total, length=50):
    """Prints a console progress bar."""
    percent = "{0:.1f}".format(100 * (iteration / float(total)))
    filled_length = int(length * iteration // total)
    bar = '#' * filled_length + '-' * (length - filled_length)
    print(f'\rProgress ({text}): |{bar}| {percent}% Complete', end='\r', file=sys.stderr)
    if iteration == total: 
        print()

def find_best_matches(video_path, templates, total_frames, fps):
    cap = cv2.VideoCapture(video_path)

    max_vals = [0, 0]
    best_frames = [None, None]

    for frame_count in range(total_frames):
        ret, frame = cap.read()
        if not ret:
            break

        # Skip frames that are not multiples of 5
        if frame_count % 5 != 0:
            continue

        gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        for i, template in enumerate(templates):
            result = cv2.matchTemplate(gray_frame, template, cv2.TM_CCOEFF_NORMED)
            _, max_val_temp, _, _ = cv2.minMaxLoc(result)

            if max_val_temp > max_vals[i]:
                max_vals[i] = max_val_temp
                best_frames[i] = frame_count

        print_progress_bar(video_path, frame_count + 1, total_frames)

    cap.release()

    timestamps = [frame / fps if frame is not None else None for frame in best_frames]
    return best_frames, max_vals, timestamps

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python script.py <video_path> <fps> <image_path1> <image_path2>")
        sys.exit()

    video_path = sys.argv[1]
    fps = float(sys.argv[2])
    image_paths = [sys.argv[3], sys.argv[4]]

    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print("Error: Could not open video.")
        sys.exit()

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    cap.release()

    templates = []
    for image_path in image_paths:
        template = cv2.imread(image_path, 0)
        if template is None:
            print(f"Error: Could not load image {image_path}")
            continue
        templates.append(template)

    best_frames, max_vals, timestamps = find_best_matches(video_path, templates, total_frames, fps)

    for i, image_path in enumerate(image_paths):
        if best_frames[i] is not None:
            # print(f"Image {image_path}: Best matching frame: {best_frames[i]} (at {timestamps[i]:.2f} seconds) with a score of {max_vals[i]:.4f}")
            print(f"{timestamps[i]:.2f}")
        else:
            print >> sys.stderr, f"Image {image_path}: No matching frame found."
            sys.exit(1)
