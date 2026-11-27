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

    with open(DAT_PATH.joinpath("groups_info.json"), "r") as f:
        groups_info = json.load(f)

    # get the subset with count >=5
    tags_subset = all_tags.loc[all_tags["count"] >= 5]

    # for getting the overall number of works for later normalization
    total_n_works = 0

    # we will overwrite this later, this makes the merging more smooth
    tags_subset["freq"] = 0

    # add group-specific frequencies
    for group in groups:
        print(group)
        # load group data
        group_dat_path = DAT_PATH.joinpath(group)

        groups_tag_df = read_tags_json_to_df(
            group_dat_path.joinpath("all_tags_counter.json")
        )

        col_name = group.replace(" ", "-")

        # add the number of documents in group, for normalizing
        n_works = groups_info[group]["n_works"]
        groups_tag_df[f"n-works_{col_name}"] = n_works
        total_n_works += n_works

        # calculate the group frequency of that tag
        groups_tag_df["freq"] = (groups_tag_df["count"] / n_works) * 100

        # merge with all tags
        tags_subset = tags_subset.merge(
            groups_tag_df, how="left", on="tag", suffixes=[None, f"_{col_name}"]
        )

    # calculate overall frequency of tags
    tags_subset["n-works_all"] = total_n_works
    tags_subset["freq"] = (tags_subset["count"] / total_n_works) * 100

    tags_subset.fillna(0, inplace=True)
    tags_subset.to_csv("dat/tags_w_freq.csv", index=False)


if __name__ == "__main__":
    main()
