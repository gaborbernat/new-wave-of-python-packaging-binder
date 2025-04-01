use rstest::rstest;

use crate::first_n;

#[rstest]
#[case::first_2(2, vec![2, 3])]
#[case::first_5(10, vec![2, 3, 5, 7, 11, 13, 17, 19, 23, 29])]
fn test_first_n(#[case] count: usize, #[case] outcome: Vec<u32>) {
    let got = first_n(count);
    assert_eq!(got, outcome);
}
