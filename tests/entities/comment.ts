import { Entity, PrimaryGeneratedColumn, Column, ManyToOne, OneToOne, JoinColumn } from 'typeorm'
import { Post } from './post'
import { User } from './user'

@Entity('comments')
export class Comment {
  @PrimaryGeneratedColumn()
  id: number

  @Column()
  content: string

  @ManyToOne(() => User)
  user: User

  @OneToOne(() => Post)
  @JoinColumn()
  post: Post
}
