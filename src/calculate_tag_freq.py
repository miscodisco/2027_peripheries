import pandas as pd

from pathlib import Path
import json


def read_tags_json_to_df(filepath: PosixPath) -> pd.DataFrame:
    """
    takes a json file with a tags counter, loads it, and makes it a pandas df
    """
    with open(filepath, "r") as f:
        tags = json.load(f)

    tags_df = pd.DataFrame.from_dict(tags, orient="index").reset_index()
    tags_df = tags_df.rename(columns={"index": "tag", 0: "count"})

    return tags_df


def main():
    # setup
    DAT_PATH = Path("output/")
    groups = [
        "Harry Potter",
        "Dream SMP",
        "The X-Files RPF",
        "Medium Fandoms",
        "Small Fandoms",
    ]

    # load data
    all_tags = read_tags_json_to_df(DAT_PATH.joinpath("all_tags.json"))

    # calculate overall frequency of tags
    total_tag_count = all_tags["count"].sum()
    all_tags["freq"] = (all_tags["count"] / total_tag_count) * 100

    # get the subset with count >=5
    tags_subset = all_tags.loc[all_tags["count"] >= 5]

    # add group-specific frequencies
    for group in groups:
        print(group)
        # load group data
        group_dat_path = DAT_PATH.joinpath(group)

        groups_tag_df = read_tags_json_to_df(
            group_dat_path.joinpath("all_tags_counter.json")
        )

        # calculate the group frequency of tags
        sum_tags = groups_tag_df["count"].sum()

        col_name = group.replace(" ", "_")
        groups_tag_df[f"freq"] = (groups_tag_df["count"] / sum_tags) * 100

        # merge with all tags
        tags_subset = tags_subset.merge(
            groups_tag_df, how="left", on="tag", suffixes=[None, f"_{col_name}"]
        )

    tags_subset.fillna(0, inplace=True)
    tags_subset.to_csv("dat/tags_w_freq.csv", index=False)


if __name__ == "__main__":
    main()
