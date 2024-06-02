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
        print(file=sys.stderr)

def find_best_matches(video_path, templates, total_frames, fps, frame_skip):
    cap = cv2.VideoCapture(video_path)

    max_vals = [0, 0]
    best_frames = [None, None]

    for frame_count in range(total_frames):
        ret, frame = cap.read()
        if not ret:
            break

        # Skip frames according to the frame_skip value
        if frame_count % frame_skip != 0:
            continue

        gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

        for i, template in enumerate(templates):
            result = cv2.matchTemplate(gray_frame, template, cv2.TM_CCOEFF_NORMED)
            _, max_val_temp, _, _ = cv2.minMaxLoc(result)

            if max_val_temp > max_vals[i]:
                max_vals[i] = max_val_temp
                best_frames[i] = frame_count

        print_progress_bar(f"{video_path} at {frame_skip} frame skip", frame_count + 1, total_frames)

    print(file=sys.stderr)
    cap.release()

    timestamps = [frame / fps if frame is not None else None for frame in best_frames]
    return best_frames, max_vals, timestamps

def find_matching_frames(video_path, fps, image_paths, frame_skip_options):
    cap = cv2.VideoCapture(video_path)
    if not cap.isOpened():
        print("Error: Could not open video.")
        sys.exit(1)

    total_frames = int(cap.get(cv2.CAP_PROP_FRAME_COUNT))
    cap.release()

    templates = []
    for image_path in image_paths:
        template = cv2.imread(image_path, 0)
        if template is None:
            print(f"Error: Could not load image {image_path}")
            continue
        templates.append(template)

    for frame_skip in frame_skip_options:
        best_frames, max_vals, timestamps = find_best_matches(video_path, templates, total_frames, fps, frame_skip)
        
        if best_frames[0] is not None and best_frames[1] is not None:
            # Check if the first image match is in the first third and the second image match is in the last third
            if (best_frames[0] / total_frames <= 1/20) and (best_frames[1] / total_frames >= 2/3):
                for i, image_path in enumerate(image_paths):
                    print(f"{timestamps[i]:.2f}")
                break
        elif frame_skip == frame_skip_options[-1]:
            print(f"Matching frames not found for given constraints.")
            sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 5:
        print("Usage: python script.py <video_path> <fps> <image_path1> <image_path2>")
        sys.exit(1)

    video_path = sys.argv[1]
    fps = float(sys.argv[2])
    image_paths = [sys.argv[3], sys.argv[4]]

    # Define frame skip options (starting from each 60th frame, then each 30th, and so on...)
    frame_skip_options = [120, 60, 30, 15, 10, 5]

    find_matching_frames(video_path, fps, image_paths, frame_skip_options)
