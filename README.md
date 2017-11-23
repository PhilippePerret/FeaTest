# FeaTest

“FeaTest” is FDD (Feature Driven Developpment) command line tool built on Ruby/RSpec.

FeaTest is a tool that supports Feature Driven Development (FDD) - a agile method for developing software or website that aims to enhance software quality and reduce maintenance costs.

FeaTest organizes tests in feature steps written in plain language and produces reports indicating whether the software or the website behaves according to the specification or not.

FeaTest reduces the effort to keep requirements specifications, tests and documentation in sync - with Featest they are all the same documents - a single source of truth for everyone on the team.

## FeaTest Sheet Sample


    STEP: FORUM
    =================
    : ^     ^
    : |     |_____ Future folder name 
    : |
    : |_______  Step indicator. Will be a main folder in FEATEST
    :           Relates to `--step=` in options command line. 
    : 
    : <––– Comments
    
    FEATURES
    -------- : <––– Lines composed with '-'s or '='s are simply ignored
    
    : This section describes all of the step features (fonctionalities), 
    : par type d'utilisateur.
    : Ici, le `as` fait référence à l'option `--as=U-TYPE`
    
    : User type
    : Relates to `--as=` in options command line.
    : In this featest sheet, privileges of users are ascendant.
    :
      AS: VISITOR
      -----------
    
    :           Computer features name. Featest add 'can' or            | 
    :           'cant' in front of these name to find the test          |-----------.
    :           file of the feature/fonctionality.                      |           |
    :           For instance, for the first feature 'read_subject_list' |           |
    :           it'll look for a 'forum/feats/can_read_subject_list.rb' |
    :           file and a 'forum/ftests/cant_read_subject_list.rb'     |
    :           file.
    :                                                                               |
    : Here are describe in human language all of the features                       |
    : for a "visitor" user. They start with a asterisk (*).                         |
    :                                                                               v
        * can read subject list.                                           --- read_subject_list
        * can read last message list.                                      --- read_last_message_list 
        * can read any message.                                            --- read_message
        * -
    :   ^ ^
    :   | |___  The minus sign ('-') indicates that 'visitor' user
    :   |       CAN NOT do what next users can. And it will be tested.
    :   |       For instance, he can not answer questions.
    :   |
    :   |______ A asterisk defines a new feature/fonctionality.
    :

    : Next user type with more privileges. His name will serve to name a folder    
    : in the step main folder.
    
      AS: SUSCRIBER
      --------------

    : This section describes what a 'suscriber' 
    : can do in 'forum' step.
    
    :     .------------ The '+' sign indicates that this user
    :     |             can do everything that previous ones can
    :     |             do. And it will be tested.
    :     v
        * +
        * can answer questions                                              --- answer_question 
        * can create a new subject                                          --- create_subject
        * can create a new post                                             --- create_post
        * can modify a post of their                                        --- modify_their_posts
        * can suscribe to a subject                                         --- suscribe_subject 
        * can unsuscribe to a subject                                       --- mark_read_not_read_on_page
        [etc]
    
        : A feature group title.                                              
        : Just for clarity.                               
        *** Deal with their ToC of posts 

        * can see their customizable posts table of contents (cToc)         --- see_own_post_ctoc
        * can add a post to their customisable toc                          --- add_post_to_ctoc
        * can remove a post from their cToc                                 --- sup_post_from_ctoc
        [etc.]
        * -
    :     ^
    :     |
    :     |_________ They can not do what next user can do, and it will 
    :                be tested.
    
    
      AS: ADMIN
      ------------
    
        * +
        * can remove any post                                               --- remove_any_post
        * can remove any subject                                            --- remove_any_subject
        * can modify any post                                               --- modify_any_post
        [etc]                                                               --- force_update_all_page
    
        -* remove the forum database                                        --- remove_forum_database
    :   ^
    :   |
    :   |________ A '-*' defines a 'no-feature', i.e. something user can not   
    :             in particular.
