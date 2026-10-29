import pandas as pd

from pathlib import Path
from collections import Counter
import json


def main():
    DAT_PATH = Path("dat/")
    OUT_PATH = Path("output/")

    tags = pd.read_csv(DAT_PATH.joinpath("tags_data_anon.csv"))

    groups = [
        "Harry Potter",
        "Dream SMP",
        "The X-Files RPF",
        "Medium Fandoms",
        "Small Fandoms",
    ]

    for group in groups:
        subset = tags.loc[tags["label"] == group]

        angst_count = 0
        fluff_count = 0
        hurtcomfort_count = 0

        bang_tags = []
        slash_tags = []

        full_tags_list = []
        n_works = 0

        for _, row in subset.iterrows():
            row_tags = row["tags"][1:-1].replace("'", "")
            row_tags_list = row_tags.split(", ")

            for tag in row_tags_list:
                if "/" in tag:
                    slash_tags.append(tag)
                if "!" in tag:
                    bang_tags.append(tag)
                if tag == "Angst":
                    angst_count += 1
                if tag == "Fluff":
                    fluff_count += 1
                if tag == "Hurt/Comfort":
                    hurtcomfort_count += 1

            full_tags_list.extend(row_tags_list)
            n_works += 1

        group_out_path = OUT_PATH.joinpath(group)
        group_out_path.mkdir(exist_ok=True)

        tags_counter = Counter(full_tags_list)
        bang_tags_counter = Counter(bang_tags)
        slash_tags_counter = Counter(slash_tags)

        group_dict = {
            "n_works": n_works,
            "angst_count": angst_count,
            "fluff_count": fluff_count,
            "hurt_comfort_count": hurtcomfort_count,
            "n_bang_tags": len(bang_tags),
            "n_slash_tags": len(slash_tags),
        }

        with open(group_out_path.joinpath("all_tags_counter.json"), "w") as f:
            json.dump(tags_counter, f)

        with open(group_out_path.joinpath("bang_tags_counter.json"), "w") as f:
            json.dump(bang_tags_counter, f)

        with open(group_out_path.joinpath("slash_tags_counter.json"), "w") as f:
            json.dump(slash_tags_counter, f)

        with open(group_out_path.joinpath("group_info.json"), "w") as f:
            json.dump(group_dict, f)


if __name__ == "__main__":
    main()
